import Foundation
import CoreImage

class SyntheticsTask {

  let source: AnnotatedImage
  let settings: WorkspaceSettings
  let operations: [Operation]
  let resultUrl: URL

  var resultAnnotations: [Annotation]!
  var resultImage: CIImage!
  
  init(annotatedImage: AnnotatedImage, settings: WorkspaceSettings, operations: [Operation]) {
    self.source = annotatedImage
    self.settings = settings
    self.operations = operations
    self.resultUrl = annotatedImage.url
      .deletingPathExtension()
      .appendingPathExtension(UUID.tiny())
      .appendingPathExtension(annotatedImage.url.pathExtension)
  }

  func applyFlip() {
    let size = resultImage.extent.size
    resultAnnotations = resultAnnotations.map { (annotation: Annotation) in
      let newCoords = CGRect(
        origin: CGPoint(x: size.width - annotation.coordinates.origin.x, y: annotation.coordinates.origin.y),
        size: annotation.coordinates.size
      )
      // Another way
      // let newCoords = annotation.coordinates.applying(CGAffineTransform(scaleX: -1, y: 1).translatedBy(x: -size.width - annotation.coordinates.size.width, y: 0))
      return Annotation(label: annotation.label, coordinates: newCoords)
    }
    resultImage = resultImage.transformed(by: .init(scaleX: -1, y: 1))
    resultImage = resultImage.transformed(by: .init(translationX: -resultImage.extent.origin.x, y: -resultImage.extent.origin.y))
  }

  func applyScale() {
    let randomScaleX = CGFloat.random(in: 0.75 ..< 1.25)
    let randomScaleY = CGFloat.random(in: 0.75 ..< 1.25)
    let scaleTransform = CGAffineTransform(scaleX: randomScaleX, y: randomScaleY)

    resultAnnotations = resultAnnotations.map { (annotation: Annotation) in
      let newCoords = annotation.coordinates.applying(scaleTransform).pixelRound
      return Annotation(label: annotation.label, coordinates: newCoords)
    }
    resultImage = resultImage.transformed(by: scaleTransform)
  }

  func applyRotation() {
    let randomAngle = CGFloat.random(in: -.pi ..< .pi)
    let originalExtent = resultImage.extent

    resultImage = resultImage.rotateInPlace(angle: randomAngle)

    let rotateTransform = CGAffineTransform(rotationAngle: randomAngle, center: originalExtent.center)
    resultAnnotations = resultAnnotations.map { (annotation: Annotation) in
      let newCoords = annotation.coordinates
        .centerToBottomLeftCoords
        .flipCoordSystem(container: originalExtent)
        .applying(rotateTransform).pixelRound
        .reframe(source: originalExtent, target: resultImage.extent)
        .flipCoordSystem(container: resultImage.extent)
        .bottomLeftToCenterCoords
      return Annotation(label: annotation.label, coordinates: newCoords)
    }
  }

  func applyBackground() {

    guard let backgroundsUrl = settings.backgrounds else {
      // FIXME: this produces a copy of the original image with no background, better just skip this entire filter
      return
    }

    let backgroundUrls = try! FileManager.default.contentsOfDirectory(at: backgroundsUrl, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]).filter { $0.path.lowercased().hasSuffix(".png") }
    let backgroundUrl = backgroundUrls[Int.random(in: 0 ..< backgroundUrls.count)]

    var bgImage = CIImage(contentsOf: backgroundUrl)!
        
    // If background doesn't fit, we scale it up
    let imageSize = resultImage.extent.size
    var bgSize = bgImage.extent.size
    if imageSize.width > bgSize.width || imageSize.height > bgSize.height {
      let bgScaleX: CGFloat
      let bgScaleY: CGFloat
      if imageSize.width > bgSize.width {
        bgScaleX = imageSize.width / bgSize.width
      } else {
        bgScaleX = 1
      }
      if imageSize.height > bgSize.height {
        bgScaleY = imageSize.height / bgSize.height
      } else {
        bgScaleY = 1
      }
      bgImage = bgImage.transformed(by: CGAffineTransform(scaleX: bgScaleX, y: bgScaleY))
      bgSize = bgImage.extent.size
    }

    let upBoundX = bgSize.width - imageSize.width
    let upBoundY = bgSize.height - imageSize.height
    let randomX = CGFloat.random(in: 0 ... upBoundX)
    let randomY = CGFloat.random(in: 0 ... upBoundY)

    let translateTransform = CGAffineTransform(translationX: randomX, y: randomY)
    let originalExtent = resultImage.extent
    resultImage = resultImage.transformed(by: translateTransform).composited(over: bgImage)

    resultAnnotations = resultAnnotations.map { (annotation: Annotation) in
      let newCoords = annotation.coordinates
        .flipCoordSystem(container: originalExtent)
        .applying(translateTransform)
        .flipCoordSystem(container: resultImage.extent)
      return Annotation(label: annotation.label, coordinates: newCoords)
    }
  }

  func applyCrop() {

    let randomX = CGFloat.random(in: 0 ... resultImage.extent.width / 5)
    let randomY = CGFloat.random(in: 0 ... resultImage.extent.height / 5)
    let randomWidth = CGFloat.random(in: (resultImage.extent.width - randomX) * 2 / 3 ... resultImage.extent.width - randomX)
    let randomHeight = CGFloat.random(in: (resultImage.extent.height - randomY) * 2 / 3 ... resultImage.extent.height - randomY)
    let cropExtent = CGRect(x: randomX, y: randomY, width: randomWidth, height: randomHeight)

    let originalExtent = resultImage.extent
    let translation = CGAffineTransform(translationX: -randomX, y: -randomY)
    resultImage = resultImage.cropped(to: cropExtent).transformed(by: translation)

    resultAnnotations = resultAnnotations.compactMap { (annotation: Annotation) in

      let coords = annotation.coordinates
        .centerToBottomLeftCoords
        .flipCoordSystem(container: originalExtent)
        .applying(translation)
      
      return coords.intersects(resultImage.extent)
      ? Annotation(
        label: annotation.label,
        coordinates: coords
          .intersection(resultImage.extent)
          .flipCoordSystem(container: resultImage.extent)
          .bottomLeftToCenterCoords
      )
      : nil
    }
  }

  func applyBlur() {
    resultAnnotations = resultAnnotations.map {
      Annotation(label: $0.label, coordinates: $0.coordinates)
    }
    let originalExtent = resultImage.extent
    resultImage = resultImage.applyingGaussianBlur(sigma: 10.0)
    resultImage = resultImage.cropped(to: originalExtent)
  }

  func applyMonochrome() {
    resultAnnotations = resultAnnotations.map {
      Annotation(label: $0.label, coordinates: $0.coordinates)
    }
    resultImage = resultImage.applyingFilter("CIColorMonochrome", parameters: [
      kCIInputColorKey: CIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1)),
      kCIInputIntensityKey: NSNumber(value: 1.0)
    ])
  }

  func applyEmboss() {
    resultAnnotations = resultAnnotations.map {
      Annotation(label: $0.label, coordinates: $0.coordinates)
    }

    let originalExtent = resultImage.extent
    let floatArr: [CGFloat] = [1, 0, -1, 2, 0, -1, 1, 0, -1]
    resultImage = resultImage.applyingFilter("CIConvolution3X3", parameters: [
      kCIInputWeightsKey: CIVector(values: floatArr, count: Int(floatArr.count)),
      kCIInputBiasKey: NSNumber(value: 0.5),
    ])
    resultImage = resultImage.cropped(to: originalExtent)
  }

  func applyNoise() {

    resultAnnotations = resultAnnotations.map {
      Annotation(label: $0.label, coordinates: $0.coordinates)
    }

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
          kCIInputBackgroundImageKey: resultImage!
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

    resultImage = oldFilmImage.cropped(to: resultImage.extent)
  }

  func process() {
    resultAnnotations = source.annotations
    resultImage = CIImage(contentsOf: source.url)!
    for op in operations {
      switch op {
      case .flip:
        applyFlip()
      case .scale:
        applyScale()
      case .rotate:
        applyRotation()
      case .background:
        applyBackground()
      case .blur:
        applyBlur()
      case .monochrome:
        applyMonochrome()
      case .emboss:
        applyEmboss()
      case .noise:
        applyNoise()
      case .crop:
        applyCrop()
      }
    }
    SyntheticsProcessor.shared.save(resultImage, toUrl: resultUrl)
  }
}

extension Array where Element == SyntheticsTask {

  func processAll(completion: @escaping (SyntheticsTask) -> ()) {
    DispatchQueue.global(qos: .userInteractive).async {
      self.forEach { task in
        task.process()
        completion(task)
      }
    }
  }
}
