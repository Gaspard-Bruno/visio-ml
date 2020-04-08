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
    
    for url in backgrounds {
      let (imageOut, annotationOut) = applyBackground(image, annotated, url)
      resultingImages.append(imageOut)
      resultingAnnotated.append(annotationOut)
    }
    
    return FilterResult(images: resultingImages, annotatedImages: resultingAnnotated)
  }
  
  
  func applyBackground(_ image: ImageModel, _ annotation: ImageAnnotationModel, _ bgUrl: URL)  -> (ImageModel, ImageAnnotationModel) {

    var resultingImage: ImageModel
    var resultingAnnotation: ImageAnnotationModel
    var resultingCiImage: CIImage

    let newUrl = image.url
      .deletingPathExtension()
      .appendingPathExtension(bgUrl.lastPathComponent)

    let bgImage = CIImage(contentsOf: bgUrl)!
    let width = image.ciImage.extent.maxX
    let height = image.ciImage.extent.maxY
    let size = CGSize(width: width, height: height)
    let bgSize = CGSize(width: bgImage.extent.maxX, height: bgImage.extent.maxY)

    let randomScaleX = parameters.workspace.randomScale ? CGFloat.random(in: 0.75 ..< 1.25) : 1

    let randomScaleY =
      parameters.workspace.randomScale
        ? parameters.workspace.keepAspectRatio
          ? randomScaleX
          : CGFloat.random(in: 0.75 ..< 1.25)
        : 1

    let scaleTransform = CGAffineTransform(scaleX: randomScaleX, y: randomScaleY)
    let scaledSize = size.applying(scaleTransform)
    
    let upBoundX = bgSize.width - scaledSize.width
    let randomX = parameters.workspace.randomPosition ? CGFloat.random(in: 0 ..< upBoundX) : 0
    let upBoundY = bgSize.height - scaledSize.height
    let randomY =  parameters.workspace.randomPosition ? CGFloat.random(in: 0 ..< upBoundY) : 0
    let translateTransform = CGAffineTransform(translationX: randomX, y: randomY)

    let transform = scaleTransform.concatenating(translateTransform)

    let transformed = image.ciImage.transformed(by: transform)
    resultingCiImage = transformed.composited(over: bgImage)

    // if crop {
    //let croppedBg = bgImage.cropped(to: image.ciImage.extent)
    //resultingCiImage = image.ciImage.composited(over: croppedBg)

    if parameters.workspace.noiseLayer {
      let coloredNoise = CIFilter(name:"CIRandomGenerator")!
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

      let scaledAnnotation = label.coordinates.asRect.applying(scaleTransform)
      let transformedAnnotation = moveAnnotation(scaledAnnotation, from: scaledSize, to: bgSize).applying(makeAnnotationTransform(translateTransform))

      let newCoordinates = LabelModel.CoordinatesModel(transformedAnnotation)
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
