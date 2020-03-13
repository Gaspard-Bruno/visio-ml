import SwiftUI

struct LabelDetails: View {
  @Binding var label: LabelModel
  var index: Int
  @EnvironmentObject var dataStore: DataStore

  var selected: Bool {
    index == dataStore.selected
  }

  var body: some View {
    VStack(alignment: .leading) {
      if selected {
        TextField("Label", text: _label.label)
      } else {
        Text("\(label.label)")
        .onTapGesture {
          self.dataStore.selected = self.index
        }
        .frame(maxWidth: .infinity)
      }

      Text("x: \(label.coordinates.x)")
      Text("y: \(label.coordinates.x)")
      Text("width: \(label.coordinates.x)")
      Text("height: \(label.coordinates.x)")
      if selected {
        Button("Remove") {
          self.dataStore.selected = nil
          self.dataStore.labels.remove(at: self.index)
        }
      }
    }
    .padding()
    .font(.system(.body, design: .monospaced))
  }
}


struct LabelDetails_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      LabelDetails(label: .constant(LabelModel.specimen), index: 0)
      LabelDetails(label: .constant(LabelModel.specimen), index: 1)
    }
    .previewLayout(.sizeThatFits)
    .environmentObject(DataStore())
  }
}
