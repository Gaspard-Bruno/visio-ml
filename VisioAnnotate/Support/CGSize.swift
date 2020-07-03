import CoreGraphics

extension CGSize {
  var pixelRound: CGSize {
    .init(width: self.width.pixelRound, height: self.height.pixelRound)
  }

  func scaledBy(_ factor: CGFloat) -> CGSize {
    return self.applying(.init(scaleX: factor, y: factor))
  }
}
