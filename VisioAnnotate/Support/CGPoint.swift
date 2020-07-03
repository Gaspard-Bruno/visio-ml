import CoreGraphics

extension CGPoint {
  var pixelRound: CGPoint {
    .init(x: self.x.pixelRound, y: self.y.pixelRound)
  }

  func scaledBy(_ factor: CGFloat) -> CGPoint {
    return self.applying(.init(scaleX: factor, y: factor))
  }
}

