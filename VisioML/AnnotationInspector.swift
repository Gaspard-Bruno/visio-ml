import SwiftUI

struct AnnotationInspector: View {

  @State var editting = false
  @State var saving = false
  @State var newName = ""
  @State var x = ""
  @State var y = ""
  @State var width = ""
  @State var height = ""

  @Binding var annotations: [Annotation]
  @Binding var showAnnotationLabels: Bool

  var annotationsPresent: Bool {
    annotations.count > 0
  }

  var annotationSelected: Bool {
    annotations.hasSelected
  }

  var annotation: Annotation {
    annotations[annotations.selectedIndex]
  }

  var body: some View {
    VStack {
      Toggle("Show annotation labels", isOn: $showAnnotationLabels)
      .padding()

      if annotationsPresent && annotationSelected {
        annotationBody
      } else {
        VStack {
          Text(
            annotationsPresent
            ? "Select an existing annotation to view or edit details."
            : "Create a new annotation by dragging over the image."
          )
          Spacer()
          footer
        }
        .foregroundColor(.secondary)
        .padding()
      }
    }
  }

  var annotationBody: some View {
    VStack {
      if editting {
        TextField("Label", text: $newName)
      } else {
        Text(annotation.label)
      }
      Divider()
      fields
      Divider()
      buttons
      Spacer()
      footer
    }
    .padding()
    .onReceive(AppData.shared.$annotatedImages) { _ in
      // Something changed with the images
      // We are interested in the image/annotation selection
      if !self.saving {
        self.cancelEditting()
      }
    }
  }

  var fields: some View {
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
    .environment(\.isEnabled, editting && !saving)
  }

  var buttons: some View {
    Group {
      HStack {
        if editting {
          Button("Save", action: self.save)
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
    }
  }

  var footer: some View {
    Text("\(annotations.count) annotations total.")
  }

  func cancelEditting() {
    editting = false
    newName = ""
    x = annotation.origin.x.asString
    y = annotation.origin.y.asString
    width = annotation.width.asString
    height = annotation.height.asString
  }

  func save() {
    editting = false
    saving.toggle()
    annotations[annotations.selectedIndex].label = newName
    if let cgFloat = x.cgFloat {
      annotations[annotations.selectedIndex].coordinates.origin.x = cgFloat
    }
    if let cgFloat = y.cgFloat {
      annotations[annotations.selectedIndex].coordinates.origin.y = cgFloat
    }
    if let cgFloat = width.cgFloat {
      annotations[annotations.selectedIndex].coordinates.size.width = cgFloat
    }
    if let cgFloat = height.cgFloat {
      annotations[annotations.selectedIndex].coordinates.size.height = cgFloat
    }
    x = annotation.origin.x.asString
    y = annotation.origin.y.asString
    width = annotation.size.width.asString
    height = annotation.size.width.asString
    saving.toggle()
  }
}

struct AnnotationInspector_Previews: PreviewProvider {
  static var previews: some View {
    AnnotationInspector(annotations: .constant([Annotation]()), showAnnotationLabels: .constant(true))
  }
}
