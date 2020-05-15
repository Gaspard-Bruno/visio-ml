import CoreGraphics

struct AnnotatedImage: Identifiable {
  var id: String
  var areas: [Area] = []
}
