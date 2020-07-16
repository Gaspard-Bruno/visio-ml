import Foundation
import CoreImage

extension SyntheticsTask {

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

}
