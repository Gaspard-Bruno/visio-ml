import Foundation
import CoreGraphics

extension CGFloat {
  var pixelRound: CGFloat {
    self.rounded(.awayFromZero)
  }

  var asString: String {
    NumberFormatter().string(from: NSNumber(value: Int(Double(pixelRound))))!
  }

}
