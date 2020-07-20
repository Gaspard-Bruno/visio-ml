import Foundation
import CoreImage

extension SyntheticsTask {

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
}
