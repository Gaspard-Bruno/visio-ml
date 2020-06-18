import CoreGraphics

extension CGPoint {
  var pixelRound: CGPoint {
    .init(x: self.x.pixelRound, y: self.y.pixelRound)
  }
}

