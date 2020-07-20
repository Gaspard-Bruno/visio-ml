import Foundation
import CoreImage

extension SyntheticsTask {

  func applyMonochrome() {
    resultAnnotations = resultAnnotations.map {
      Annotation(label: $0.label, coordinates: $0.coordinates)
    }
    resultImage = resultImage.applyingFilter("CIColorMonochrome", parameters: [
      kCIInputColorKey: CIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1)),
      kCIInputIntensityKey: NSNumber(value: 1.0)
    ])
  }
}
