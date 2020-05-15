import CoreGraphics

struct Area: Identifiable {
  var id: Int
  var rect: CGRect
  var isMoving = false
}
