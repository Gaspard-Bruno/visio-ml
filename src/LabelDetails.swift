import SwiftUI

struct LabelDetails: View {
  var label: LabelModel
  @ObservedObject var store = DataStore.shared

  @State private var labelName: String?
  @State private var x: CGFloat?
  @State private var y: CGFloat?
  @State private var width: CGFloat?
  @State private var height: CGFloat?

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
      self.store.selectedLabel == nil ? "" : self.labelName == nil ? self.store.selectedLabel.label : self.labelName!
    }, set: {
      self.labelName = $0
    })
  }

  private var _xBinding: Binding<String> {
    Binding<String>(get: {
      self.store.selectedLabel == nil ? "" : "\(self.x == nil ? self.store.selectedLabel.coordinates.x : self.x!)"
    }, set: {
      if let n = NumberFormatter().number(from: $0) {
        self.x = CGFloat(truncating: n)
      }
    })
  }

  private var _yBinding: Binding<String> {
    Binding<String>(get: {
      self.store.selectedLabel == nil ? "" : "\(self.y == nil ? self.store.selectedLabel.coordinates.y : self.y!)"
    }, set: {
      if let n = NumberFormatter().number(from: $0) {
        self.y = CGFloat(truncating: n)
      }
    })
  }

  private var _widthBinding: Binding<String> {
    Binding<String>(get: {
      self.store.selectedLabel == nil ? "" : "\(self.width == nil ? self.store.selectedLabel.coordinates.width : self.width!)"
    }, set: {
      if let n = NumberFormatter().number(from: $0) {
        self.width = CGFloat(truncating: n)
      }
    })
  }

  private var _heightBinding: Binding<String> {
    Binding<String>(get: {
      self.store.selectedLabel == nil ? "" : "\(self.height == nil ? self.store.selectedLabel.coordinates.height : self.height!)"
    }, set: {
      if let n = NumberFormatter().number(from: $0) {
        self.height = CGFloat(truncating: n)
      }
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
          guard let labelName = self.labelName else {
            return
          }
          self.store.selectedLabel.label = labelName

          // HACK ALERT:
          self.store.dummyToggle.toggle()
        }
        HStack {
          Text("x:")
          TextField("0.0", text: _xBinding) {
            guard let x = self.x else {
              return
            }
            self.store.selectedLabel.coordinates.x = x
            self.store.dummyToggle.toggle()
          }
        }
        HStack {
          Text("y:")
          TextField("0.0", text: _yBinding) {
            guard let y = self.y else {
              return
            }
            self.store.selectedLabel.coordinates.y = y
            self.store.dummyToggle.toggle()
          }
        }
        HStack {
          Text("width:")
          TextField("0.0", text: _widthBinding) {
            guard let width = self.width else {
              return
            }
            self.store.selectedLabel.coordinates.width = width
            self.store.dummyToggle.toggle()
          }
        }
        HStack {
          Text("height:")
          TextField("0.0", text: _heightBinding) {
            guard let height = self.height else {
              return
            }
            self.store.selectedLabel.coordinates.height = height
            self.store.dummyToggle.toggle()
          }
        }
      } else {
        Group {
          TextField("Label", text: .constant(label.label))
          HStack {
            Text("x:")
            TextField("Label", text: .constant("\(label.coordinates.x)"))
          }
          HStack {
            Text("y:")
            TextField("Label", text: .constant("\(label.coordinates.y)"))
          }
          HStack {
            Text("width:")
            TextField("Label", text: .constant("\(label.coordinates.width)"))
          }
          HStack {
            Text("height:")
            TextField("Label", text: .constant("\(label.coordinates.height)"))
          }
        }
        .environment(\.isEnabled, false)
      }

      if selected {
        VStack {
          Button("Delete") {
            self.store.deleteSelectedLabel()
          }
          Group {
            Text("Or press ") + Text("delete").italic()
          }
          .font(.footnote)
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
    .environmentObject(DataStore.shared)
  }
}
