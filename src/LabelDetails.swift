import SwiftUI

struct LabelDetails: View {
  var label: LabelModel
  @EnvironmentObject var store: DataStore

  @State private var labelName: String?

  var selectedLabel: Binding<String> {
    $store.selectedLabel.label
  }
  
  var selected: Bool {
    label == store.selectedLabel
  }
  
  var _selected: Binding<Bool> {
    Binding<Bool>(get: {
      self.selected
    }, set: {
      if $0 {
        self.store.selectedLabel = self.label
      } else {
        self.store.selectedLabel = nil
      }
    })
  }

  private var _labelCustomBinding: Binding<String> {
    Binding<String>(get: {
      self.labelName == nil ? self.store.selectedLabel.label : self.labelName!
    }, set: {
      self.labelName = $0
    })
  }

  var body: some View {
    VStack(alignment: .leading) {
      Toggle(isOn: _selected) {
        Text("Select")
      }

      //TextField("Label", text: selected ? $store.selectedLabel.label : .constant(label.label))
      
      if selected {
        TextField("Label", text: _labelCustomBinding) {
          self.store.selectedLabel.label = self.labelName!

          // HACK ALERT:
          self.store.dummyToggle.toggle()
        }
      } else {
        TextField("Label", text: .constant(label.label))
        .environment(\.isEnabled, false)
      }

      Text("x: \(label.coordinates.x)")
      Text("y: \(label.coordinates.y)")
      Text("width: \(label.coordinates.width)")
      Text("height: \(label.coordinates.height)")
      if selected {
        Button("Delete") {
          self.store.deleteSelectedLabel()
        }
      }
    }
    .padding()
    .font(.system(.body, design: .monospaced))
  }
}


struct LabelDetails_Previews: PreviewProvider {
  static var previews: some View {
    LabelDetails(label: LabelModel.specimen)
    .previewLayout(.sizeThatFits)
    .environmentObject(DataStore())
  }
}
