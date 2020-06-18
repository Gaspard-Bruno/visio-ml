import CoreGraphics

extension CGAffineTransform {
  init(rotationAngle a: CGFloat, center: CGPoint) {
    let x = center.x
    let y = center.y
    self.init(a: cos(a), b: sin(a), c: -sin(a), d: cos(a), tx: x - x * cos(a) + y * sin(a), ty: y - x * sin(a) - y * cos(a))
  }
}
