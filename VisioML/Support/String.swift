import CoreGraphics

extension String {
  var cgFloat: CGFloat? {
    guard let asDouble = Double(self) else {
      return nil
    }
    return CGFloat(Int(asDouble.rounded()))
  }

}
