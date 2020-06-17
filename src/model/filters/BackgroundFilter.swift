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

    let randomRotation = parameters.workspace.randomScale ? CGFloat.random(in: -.pi ..< .pi) : 0
    // CGFloat.pi / 4
    
    let randomScaleX = parameters.workspace.randomScale ? CGFloat.random(in: 0.75 ..< 1.25) : 1
    let randomScaleY = parameters.workspace.randomScale
      ? parameters.workspace.keepAspectRatio
        ? randomScaleX
        : CGFloat.random(in: 0.75 ..< 1.25)
      : 1
       
//    let randomScaleX = CGFloat(1)
//    let randomScaleY = CGFloat(1)
    
    let center = CGPoint(x: image.extent.midX, y: image.extent.midY)
    let rotateScaleTransform = CGAffineTransform(translationX: center.x, y: center.y).rotated(by: randomRotation).translatedBy(x: -center.x, y: -center.y).scaledBy(x: randomScaleX, y: randomScaleY)
    //CGAffineTransform(scaleX: randomScaleX, y: randomScaleY)

    // let rotatedSize = size.applying(rotateTransform)
    let rotatedScaledSize = image.extent.applying(rotateScaleTransform).size
    
    var bgSize = bgImage.extent.size

    // If background doesn't fit, we scale it up
    if rotatedScaledSize.width > bgSize.width || rotatedScaledSize.height > bgSize.height {
      let bgScaleX: CGFloat
      let bgScaleY: CGFloat
      if rotatedScaledSize.width > bgSize.width {
        bgScaleX = rotatedScaledSize.width / bgSize.width
      } else {
        bgScaleX = 1
      }
      if rotatedScaledSize.height > bgSize.height {
        bgScaleY = rotatedScaledSize.height / bgSize.height
      } else {
        bgScaleY = 1
      }
      bgImage = bgImage.transformed(by: CGAffineTransform(scaleX: bgScaleX, y: bgScaleY))
      bgSize = bgImage.extent.size
    }

    let upBoundX = bgSize.width - rotatedScaledSize.width
    let randomX = parameters.workspace.randomPosition ? CGFloat.random(in: 0 ..< upBoundX) : 0 // CGFloat(0)
    let upBoundY = bgSize.height - rotatedScaledSize.height
    let randomY = parameters.workspace.randomPosition ? CGFloat.random(in: 0 ..< upBoundY) : 0 // CGFloat(0)
    let translateTransform = CGAffineTransform(translationX: randomX, y: randomY)

    let transform = rotateScaleTransform.concatenating(translateTransform)

    var transformed = image.transformed(by: transform)
    transformed = transformed.transformed(by: CGAffineTransform(translationX: -transformed.extent.origin.x, y: -transformed.extent.origin.y))
    resultingCiImage = transformed.composited(over: bgImage)

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
    
    var newLabels: [LabelModel] = []
    for label in annotation.annotation {

      let annotationRect = label.coordinates.asRect
      var annotationTransformed = annotationRect.applying(transform).applying(CGAffineTransform(translationX: (bgSize.width - image.extent.size.width) / 2, y: (bgSize.height - image.extent.size.height) / 2))
      //annotationTransformed = annotationTransformed.applying(CGAffineTransform(translationX: -annotationTransformed.origin.x, y: -annotationTransformed.origin.y))
      let newCoordinates = LabelModel.CoordinatesModel(annotationTransformed)
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
