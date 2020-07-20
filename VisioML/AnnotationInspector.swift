import SwiftUI

struct AnnotationInspector: View {

  @State var editting = false
  @State var newName = ""
  @State var x = ""
  @State var y = ""
  @State var width = ""
  @State var height = ""

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
      if editting {
        TextField("Label", text: $newName)
      } else {
        Text(annotation.label)
      }
      Divider()
      Group {
          HStack {
            Text("Center X:")
            Spacer()
            TextField("X position", text: $x)
            .frame(width: 40)
            .multilineTextAlignment(.trailing)
          }
          HStack {
            Text("Center Y:")
            Spacer()
            TextField("Y position", text: $y)
            .frame(width: 40)
            .multilineTextAlignment(.trailing)
          }
          HStack {
            Text("Width:")
            Spacer()
            TextField("Width", text: $width)
            .frame(width: 40)
            .multilineTextAlignment(.trailing)
          }
          HStack {
            Text("Height:")
            Spacer()
            TextField("Height", text: $height)
            .frame(width: 40)
            .multilineTextAlignment(.trailing)
          }
          // Text("X: \(annotation.coordinates.origin.x, specifier: "%.2f")")
      }
      .environment(\.isEnabled, editting)
      Divider()
      HStack {
        if editting {
          Button("Save") {
            self.editting = false
            self.annotations[self.annotations.selectedIndex].label = self.newName
            if let cgFloat = self.x.cgFloat {
              self.annotations[self.annotations.selectedIndex].coordinates.origin.x = cgFloat
            }
            if let cgFloat = self.y.cgFloat {
              self.annotations[self.annotations.selectedIndex].coordinates.origin.y = cgFloat
            }
            if let cgFloat = self.width.cgFloat {
              self.annotations[self.annotations.selectedIndex].coordinates.size.width = cgFloat
            }
            if let cgFloat = self.height.cgFloat {
              self.annotations[self.annotations.selectedIndex].coordinates.size.height = cgFloat
            }
            self.x = self.annotation.origin.x.asString
            self.y = self.annotation.origin.y.asString
            self.width = self.annotation.size.width.asString
            self.height = self.annotation.size.width.asString
          }
          Button("Cancel", action: self.cancelEditting)
        } else {
          Button("Edit") {
            self.newName = self.annotation.label
            self.editting = true
          }
        }
      }
      Button("Remove") {
        self.annotations.removeSelectedAnnotation()
      }
      Spacer()
      Text("\(annotations.count) annotations total")
    }
    .padding()
    .onReceive(AppData.shared.$annotatedImages) { _ in
      // Something changed with the images
      // We are interested in the image/annotation selection
      self.cancelEditting()
    }
  }

  func cancelEditting() {
    editting = false
    newName = ""
    self.x = self.annotation.origin.x.asString
    self.y = self.annotation.origin.y.asString
    self.width = self.annotation.width.asString
    self.height = self.annotation.height.asString
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
