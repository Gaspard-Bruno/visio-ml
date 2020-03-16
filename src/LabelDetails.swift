import SwiftUI

struct LabelDetails: View {
  @Binding var label: LabelModel
  @EnvironmentObject var dataStore: DataStore

  var selected: Bool {
    label == dataStore.selected
  }
  
  var _selected: Binding<Bool> {
    Binding<Bool>(get: {
      self.selected
    }, set: {
      if $0 {
        self.dataStore.selected = self.label
      } else {
        self.dataStore.selected = nil
      }
    })
  }

  var body: some View {
    VStack(alignment: .leading) {
      Toggle(isOn: _selected) {
        Text("Select")
      }
      TextField("Label", text: _label.label)
      Text("x: \(label.coordinates.x)")
      Text("y: \(label.coordinates.y)")
      Text("width: \(label.coordinates.width)")
      Text("height: \(label.coordinates.height)")
      if selected {
        Button("Remove") {
          self.dataStore.selected = nil
          self.dataStore.annotatedImage.annotation.removeAll { $0 == self.label }
        }
      }
    }
    .padding()
    .font(.system(.body, design: .monospaced))
  }
}


struct LabelDetails_Previews: PreviewProvider {
  static var previews: some View {
    LabelDetails(label: .constant(LabelModel.specimen))
    .previewLayout(.sizeThatFits)
    .environmentObject(DataStore())
  }
}
