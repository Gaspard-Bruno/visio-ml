import CoreGraphics

extension CGRect {

  var center: CGPoint {
    CGPoint(x: self.midX, y: self.midY)
  }

  func scaledBy(_ factor: CGFloat) -> CGRect {
    return self.applying(.init(scaleX: factor, y: factor))
  }

  func reframe(source: CGRect, target: CGRect) -> CGRect {
    let adjustX = (target.size.width - source.size.width) / 2
    let adjustY = (target.size.height - source.size.height) / 2
    return self.applying(.init(translationX: adjustX.pixelRound, y: adjustY.pixelRound))
  }

  var pixelRound: CGRect {
    .init(
      origin: self.origin.pixelRound,
      size: self.size.pixelRound
    )
  }
  
  func flipCoordSystem(container: CGRect) -> CGRect {
    CGRect(
      origin: CGPoint(
        x: self.origin.x,
        y: container.size.height - self.origin.y - size.height
      ),
      size: self.size
    )
  }
}
