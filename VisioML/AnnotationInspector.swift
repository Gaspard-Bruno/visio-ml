import SwiftUI

struct AnnotationInspector: View {

  @Binding var annotations: [Annotation]

  var annotationsPresent: Bool {
    annotations.count > 0
  }

  var annotationSelected: Bool {
    annotations.hasSelected
  }

  var annotation: Annotation {
    annotations[annotations.selectedIndex]
  }

  var annotationBody: some View {
    VStack(alignment: .leading) {
      TextField(annotation.label, text: $annotations[annotations.selectedIndex].label)
      Divider()
      Group {
        Text("X: \(annotation.coordinates.origin.x, specifier: "%.2f")")
        Text("Y: \(annotation.coordinates.origin.y, specifier: "%.2f")")
        Text("Width: \(annotation.width, specifier: "%.2f")")
        Text("Height: \(annotation.height, specifier: "%.2f")")
      }
      Divider()
      Button("Remove") {
        self.annotations.removeSelectedAnnotation()
      }
      Spacer()
      Text("\(annotations.count) annotations total")
    }
    .padding()
  }

  var body: some View {
    VStack(alignment: .leading) {
      if !annotationsPresent {
        Text("Create a new annotation by dragging over of the image")
        .foregroundColor(.secondary)
        .padding()
        Spacer()
      } else if !annotationSelected {
        VStack {
          Text("Select an annotation to view/edit details")
          Spacer()
          Text("\(annotations.count) annotations total")
        }
        .foregroundColor(.secondary)
        .padding()
      } else {
        annotationBody
      }
    }
  }
}

struct AnnotationInspector_Previews: PreviewProvider {
  static var previews: some View {
    AnnotationInspector(annotations: .constant([Annotation]()))
  }
}
