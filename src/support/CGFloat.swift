import CoreGraphics

extension CGFloat {
  var pixelRound: CGFloat {
    self.rounded(.awayFromZero)
  }
}
