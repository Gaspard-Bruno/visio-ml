import CoreGraphics

extension CGRect {

  var center: CGPoint {
    CGPoint(x: midX, y: midY)
  }

  func scaledBy(_ factor: CGFloat) -> CGRect {
    return applying(.init(scaleX: factor, y: factor))
  }

  func reframe(source: CGRect, target: CGRect) -> CGRect {
    let adjustX = (target.size.width - source.size.width) / 2
    let adjustY = (target.size.height - source.size.height) / 2
    return applying(.init(translationX: adjustX.pixelRound, y: adjustY.pixelRound))
  }

  var pixelRound: CGRect {
    .init(
      origin: origin.pixelRound,
      size: size.pixelRound
    )
  }
  
  func flipCoordSystem(container: CGRect) -> CGRect {
    CGRect(
      origin: CGPoint(
        x: origin.x,
        y: container.size.height - origin.y - size.height
      ),
      size: size
    )
  }

  var centerToBottomLeftCoords: CGRect {
    CGRect(
      origin: CGPoint(
        x: origin.x - size.width / 2,
        y: origin.y - size.height / 2
      ),
      size: size
    )
  }

  var bottomLeftToCenterCoords: CGRect {
    CGRect(origin: center, size: size)
  }
  
  
  // mac only, flipped coordinate system
  func exclusion(_ rect: CGRect) -> CGRect {
    guard self.intersects(rect) else {
      return self
    }
    let i = self.intersection(rect)
    guard width > i.width || height > i.height else {
      return CGRect.null
    }
    let newSize = CGSize(
      width: width == i.width ? width : width - i.width,
      height: height == i.height ? height : height - i.height
    )
    return CGRect(
      origin: CGPoint(
        x: width == i.width || origin.x != i.origin.x ? origin.x : i.maxX,
        y: height == i.height || origin.y != i.origin.y ? origin.y : i.maxY
      ),
      size: newSize
    )
  }
}
