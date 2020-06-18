import CoreImage

struct BackgroundFilter: Filter {
  
  struct Input: FilterInOut {
    var images: [ImageModel]
    var annotatedImages: [ImageAnnotationModel]
    var workspace: WorkspaceModel
  }
  
  var parameters: Input
  
  func ciImageSize(_ ciImage: CIImage) -> CGSize {
    CGSize(width: ciImage.extent.maxX, height: ciImage.extent.maxY)
  }

  func makeOffset(imageSize: CGSize, annotation: CGRect) -> CGSize {
    CGSize(width: annotation.origin.x - annotation.size.width / 2, height: -(imageSize.height - annotation.origin.y - annotation.size.height / 2))
  }

  func makeAnnotationTransform(_ transform: CGAffineTransform) -> CGAffineTransform {
    // CGAffineTransform(translationX: transform.tx, y: -transform.ty)
    var newTransform = transform
    newTransform.ty = -transform.ty
    return newTransform
  }

  func moveAnnotation(_ annotation: CGRect, from : CGSize, to: CGSize) -> CGRect {
    CGRect(
      origin: CGPoint(
        x: annotation.origin.x,
        y: annotation.origin.y + (to.height - from.height)
      ),
      size: annotation.size
    )
  }

  var backgrounds: [URL] {
    parameters.workspace.backgrounds
  }
 
  func apply(image: ImageModel, annotated: ImageAnnotationModel) -> FilterResult {
    var resultingImages: [ImageModel] = []
    var resultingAnnotated: [ImageAnnotationModel] = []
    
    let backgrounds: [URL]
    if parameters.workspace.everyBackground {
      backgrounds = self.backgrounds
    } else {
      backgrounds = [ self.backgrounds[Int.random(in: 0 ..< self.backgrounds.count)] ]
    }
    
    for url in backgrounds {
      let (imageOut, annotationOut) = applyBackground(image, annotated, url)
      resultingImages.append(imageOut)
      resultingAnnotated.append(annotationOut)
      DispatchQueue.main.async {
        self.parameters.workspace.processedFiles += 1
      }
    }
    return FilterResult(images: resultingImages, annotatedImages: resultingAnnotated)
  }
  
  
  func applyBackground(_ imageModel: ImageModel, _ annotation: ImageAnnotationModel, _ bgUrl: URL)  -> (ImageModel, ImageAnnotationModel) {

    var resultingImage: ImageModel
    var resultingAnnotation: ImageAnnotationModel
    var resultingCiImage: CIImage

    let newUrl = imageModel.url
      .deletingPathExtension()
      .appendingPathExtension(bgUrl.lastPathComponent)

    let image = imageModel.ciImage
    var bgImage = CIImage(contentsOf: bgUrl)!

    // Randomized angle and scale factors
    let randomAngle =
      // CGFloat.pi / 4
      // CGFloat(0)
      parameters.workspace.randomScale ? CGFloat.random(in: -.pi ..< .pi) : 0

    let randomScaleX =
      // CGFloat(1)
      parameters.workspace.randomScale ? CGFloat.random(in: 0.75 ..< 1.25) : 1
    let randomScaleY =
      // CGFloat(1)
      parameters.workspace.randomScale ? parameters.workspace.keepAspectRatio ? randomScaleX : CGFloat.random(in: 0.75 ..< 1.25) : 1

    // Rotate image
    let rotatedImage = image.rotateInPlace(angle: randomAngle)
    
    // Scale rotated image
    let scaleTransform = CGAffineTransform(scaleX: randomScaleX, y: randomScaleY)
    let scaledRotatedImage = rotatedImage.transformed(by: scaleTransform)
        
    // If background doesn't fit, we scale it up
    let scaledRotatedSize = scaledRotatedImage.extent.size
    var bgSize = bgImage.extent.size
    if scaledRotatedSize.width > bgSize.width || scaledRotatedSize.height > bgSize.height {
      let bgScaleX: CGFloat
      let bgScaleY: CGFloat
      if scaledRotatedSize.width > bgSize.width {
        bgScaleX = scaledRotatedSize.width / bgSize.width
      } else {
        bgScaleX = 1
      }
      if scaledRotatedSize.height > bgSize.height {
        bgScaleY = scaledRotatedSize.height / bgSize.height
      } else {
        bgScaleY = 1
      }
      bgImage = bgImage.transformed(by: CGAffineTransform(scaleX: bgScaleX, y: bgScaleY))
      bgSize = bgImage.extent.size
    }

    let upBoundX = bgSize.width - scaledRotatedSize.width
    let upBoundY = bgSize.height - scaledRotatedSize.height

    let randomX =
      //CGFloat(0)
      parameters.workspace.randomPosition ? CGFloat.random(in: 0 ..< upBoundX) : 0

    let randomY =
      // CGFloat(0)
      parameters.workspace.randomPosition ? CGFloat.random(in: 0 ..< upBoundY) : 0

    let translateTransform = CGAffineTransform(translationX: randomX, y: randomY)
    let translatedScaledRotatedImage = scaledRotatedImage.transformed(by: translateTransform)
    resultingCiImage = translatedScaledRotatedImage.composited(over: bgImage)

    // if crop {
    //let croppedBg = bgImage.cropped(to: image.ciImage.extent)
    //resultingCiImage = image.ciImage.composited(over: croppedBg)

    // TODO: randomize
    let ws = parameters.workspace
    let indices = [
      ws.embossFilter ? 0 : nil,
      ws.blurFilter ? 1 : nil,
      ws.colorFilter ? 2 : nil,
      ws.noiseLayer ? 3 : nil,
    ].compactMap { $0 }
    
    var embossFilter = false
    var blurFilter = false
    var colorFilter = false
    var noiseLayer = false

    if indices.count > 0 {
      let index = Int.random(in: 0 ..< indices.count)
      let filterId = indices[index]
      embossFilter = filterId == 0
      blurFilter = filterId == 1
      colorFilter = filterId == 2
      noiseLayer = filterId == 3
    }
    
    if embossFilter {
      let floatArr: [CGFloat] = [1, 0, -1, 2, 0, -1, 1, 0, -1]
      let convolution = CIFilter(name:"CIConvolution3X3", parameters: [
        kCIInputImageKey: resultingCiImage,
        kCIInputWeightsKey: CIVector(values: floatArr, count: Int(floatArr.count)),
        kCIInputBiasKey: NSNumber(value: 0.5),
      ])!
      resultingCiImage = convolution.outputImage!.cropped(to: resultingCiImage.extent)
    }

    if blurFilter {
      let blur = CIFilter(name: "CIGaussianBlur", parameters: [
        kCIInputImageKey: resultingCiImage,
        kCIInputRadiusKey: NSNumber(value: 10.0)
      ])!
      resultingCiImage = blur.outputImage!
    }

    if colorFilter {
      let color = CIFilter(name: "CIColorMonochrome", parameters: [
        kCIInputImageKey: resultingCiImage,
        kCIInputColorKey: CIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1)),
        kCIInputIntensityKey: NSNumber(value: 1.0)
      ])!
      resultingCiImage = color.outputImage!
    }

    if noiseLayer {
      let coloredNoise = CIFilter(name: "CIRandomGenerator")!
      let noiseImage = coloredNoise.outputImage!
      let whitenVector = CIVector(x: 0, y: 1, z: 0, w: 0)
      let fineGrain = CIVector(x:0, y:0.005, z:0, w:0)
      let zeroVector = CIVector(x: 0, y: 0, z: 0, w: 0)
      let whiteningFilter = CIFilter(name:"CIColorMatrix",
         parameters: [
            kCIInputImageKey: noiseImage,
            "inputRVector": whitenVector,
            "inputGVector": whitenVector,
            "inputBVector": whitenVector,
            "inputAVector": fineGrain,
            "inputBiasVector": zeroVector
          ])!
      let whiteSpecks = whiteningFilter.outputImage!
      let speckCompositor = CIFilter(name:"CISourceOverCompositing",
          parameters: [
            kCIInputImageKey: whiteSpecks,
            kCIInputBackgroundImageKey: resultingCiImage
          ]
      )!
      let speckledImage = speckCompositor.outputImage!
      let verticalScale = CGAffineTransform(scaleX: 1.5, y: 25)
      let transformedNoise = noiseImage.transformed(by: verticalScale)
      let darkenVector = CIVector(x: 4, y: 0, z: 0, w: 0)
      let darkenBias = CIVector(x: 0, y: 1, z: 1, w: 1)
      let darkeningFilter = CIFilter(name:"CIColorMatrix",
        parameters: [
          kCIInputImageKey: transformedNoise,
          "inputRVector": darkenVector,
          "inputGVector": zeroVector,
          "inputBVector": zeroVector,
          "inputAVector": zeroVector,
          "inputBiasVector": darkenBias
        ])!
      let randomScratches = darkeningFilter.outputImage!

      let grayscaleFilter = CIFilter(name:"CIMinimumComponent",
         parameters:
          [
              kCIInputImageKey: randomScratches
          ])!
      let darkScratches = grayscaleFilter.outputImage!

          let oldFilmCompositor = CIFilter(name:"CIMultiplyCompositing",
           parameters:
          [
              kCIInputImageKey: darkScratches,
              kCIInputBackgroundImageKey: speckledImage
          ])!
          let oldFilmImage = oldFilmCompositor.outputImage!

      resultingCiImage = oldFilmImage.cropped(to: resultingCiImage.extent)
    }
    
    let rotateTransform = CGAffineTransform(rotationAngle: randomAngle, center: image.extent.center)
    var newLabels: [LabelModel] = []
    for label in annotation.annotation {
      let annotation = label.coordinates.asRect.flipCoordSystem(container: image.extent)
      let rotatedAnnotation = annotation.applying(rotateTransform).pixelRound.reframe(source: image.extent, target: rotatedImage.extent)
      let scaledRotatedAnnotation = rotatedAnnotation.applying(scaleTransform).pixelRound
      let translatedScaledRotatedAnnotation = scaledRotatedAnnotation.applying(translateTransform)
      let newCoordinates = LabelModel.CoordinatesModel(translatedScaledRotatedAnnotation.flipCoordSystem(container: resultingCiImage.extent))
      let newLabel = LabelModel(label: label.label, coordinates: newCoordinates)
      newLabels.append(newLabel)
    }
    resultingAnnotation = ImageAnnotationModel(imagefilename: newUrl.lastPathComponent, annotation: newLabels)
    
    let context = CIContext()
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    do {
      try context.writePNGRepresentation(of: resultingCiImage, to: newUrl, format: .RGBA8, colorSpace: colorSpace)
    } catch {
      print("Error writing PNG.\n\n\(error.localizedDescription)")
    }
    
    resultingImage = ImageModel(url: newUrl)
    return (resultingImage, resultingAnnotation)
  }
}
