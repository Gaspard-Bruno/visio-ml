import SwiftUI

struct AnnotationInspector: View {

  @State var editting = false
  @State var saving = false
  @State var newName = ""
  @State var x = CGFloat.zero
  @State var y = CGFloat.zero
  @State var width = CGFloat.zero
  @State var height = CGFloat.zero

  @Binding var annotations: [Annotation]
  @Binding var showAnnotationLabels: Bool
  @Binding var draftCoords: CGRect?


  var xBind: Binding<String> {
    .init(
      get: { self.x.asString },
      set: {
        if let cgFloat = $0.cgFloat {
          self.x = cgFloat
          self.updateDraft()
        }
      }
    )
  }

  var yBind: Binding<String> {
    .init(
      get: { self.y.asString },
      set: {
        if let cgFloat = $0.cgFloat {
          self.y = cgFloat
          self.updateDraft()
        }
      }
    )
  }

  var widthBind: Binding<String> {
    .init(
      get: { self.width.asString },
      set: {
        if let cgFloat = $0.cgFloat {
          self.width = cgFloat
          self.updateDraft()
        }
      }
    )
  }

  var heightBind: Binding<String> {
    .init(
      get: { self.height.asString },
      set: {
        if let cgFloat = $0.cgFloat {
          self.height = cgFloat
          self.updateDraft()
        }
      }
    )
  }

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
          TextField("X position", text: xBind)
          .frame(width: 40)
          .multilineTextAlignment(.trailing)
        }
        HStack {
          Text("Center Y:")
          Spacer()
          TextField("Y position", text: yBind)
          .frame(width: 40)
          .multilineTextAlignment(.trailing)
        }
        HStack {
          Text("Width:")
          Spacer()
          TextField("Width", text: widthBind)
          .frame(width: 40)
          .multilineTextAlignment(.trailing)
        }
        HStack {
          Text("Height:")
          Spacer()
          TextField("Height", text: heightBind)
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

  func updateDraft() {
    let coords = annotation.coordinates
    let newCoords = CGRect(x: x, y: y, width: width, height: height)
    if newCoords == coords {
      draftCoords = nil
    } else {
      draftCoords = newCoords
    }
  }

  func cancelEditting() {
    draftCoords = nil
    editting = false
    newName = ""
    x = annotation.origin.x
    y = annotation.origin.y
    width = annotation.width
    height = annotation.height
  }

  func save() {
    draftCoords = nil
    editting = false
    saving.toggle()
    annotations[annotations.selectedIndex].label = newName
    annotations[annotations.selectedIndex].coordinates.origin.x = x
    annotations[annotations.selectedIndex].coordinates.origin.y = y
    annotations[annotations.selectedIndex].coordinates.size.width = width
    annotations[annotations.selectedIndex].coordinates.size.height = height
    x = annotation.origin.x
    y = annotation.origin.y
    width = annotation.size.width
    height = annotation.size.height
    saving.toggle()
  }
}

struct AnnotationInspector_Previews: PreviewProvider {
  static var previews: some View {
    AnnotationInspector(annotations: .constant([Annotation]()), showAnnotationLabels: .constant(true), draftCoords: .constant(nil))
  }
}
