import CoreGraphics

extension CGSize {
  var pixelRound: CGSize {
    .init(width: self.width.pixelRound, height: self.height.pixelRound)
  }
}
