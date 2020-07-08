import Foundation
import CoreImage

class SyntheticsTask {

  let source: AnnotatedImage
  let operations: [Operation]
  let resultUrl: URL

  var resultAnnotations: [Annotation]!
  var resultImage: CIImage!

  enum Operation {
    case flip
    case scale
    case rotate
    case blur
    case monochrome
    case emboss
    case noise
  }
  
  init(annotatedImage: AnnotatedImage, operations: [Operation]) {
    self.source = annotatedImage
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
      case .blur:
        applyBlur()
      case .monochrome:
        applyMonochrome()
      case .emboss:
        applyEmboss()
      case .noise:
        applyNoise()
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
