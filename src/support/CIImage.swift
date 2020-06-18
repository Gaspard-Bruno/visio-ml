import CoreImage
import CoreGraphics

extension CIImage {
  func rotateInPlace(angle a: CGFloat) -> CIImage {
    let rotateTransform = CGAffineTransform(rotationAngle: a)
    let offset = self.extent.applying(rotateTransform).pixelRound.origin
    let translateTransform = CGAffineTransform(translationX: -offset.x, y: -offset.y)
    let rotateAndTranslate = rotateTransform.concatenating(translateTransform)
    return self.transformed(by: rotateAndTranslate)
  }
}
