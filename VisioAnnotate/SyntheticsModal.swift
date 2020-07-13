import SwiftUI

struct SyntheticsModal: View {

  @Binding var settings: WorkspaceSettings
  @ObservedObject var appData = AppData.shared
  
  var count: Int {
    settings.markedOnly
    ? appData.annotatedImages.marked.count
    : appData.annotatedImages.count
  }

  var filteredCombinations: [[Operation]] {
    Operation.validCombinations.filter { opset in
      // combination does not contain an excluded filter
      !opset.reduce(into: false) { result, op in
        result = result || self.settings.excludeOperations.contains(op)
      }
    }
  }
  
  var totalSynthetics: Int {
    count * settings.times * filteredCombinations.count
  }
  
  var timesFormatter: some Formatter {
    let nf = NumberFormatter()
    nf.allowsFloats = false
    nf.minimumIntegerDigits = 1
    nf.maximumIntegerDigits = 3
    nf.maximumSignificantDigits = 3
    nf.maximum = 100
    nf.minimum = 1
    return nf
  }

  func makeBinding(_ op: Operation) -> Binding<Bool> {
    .init(get: {
      self.settings.excludeOperations.contains(op)
    }, set: {
      let contained = self.settings.excludeOperations.contains(op)
      if $0 && !contained {
        self.settings.excludeOperations.append(op)
      }
      if !$0 && contained {
        self.settings.excludeOperations.removeAll(where: { $0 == op })
      }
    })
  }

  var body: some View {
    VStack {
      Text("Synthetic image generator")
      ScrollView {
        VStack {
          Form {
            Section(
              footer: Text("Will apply to \(count) objets")
            ) {
              Toggle("Apply to marked images only", isOn: $settings.markedOnly)
            }
            Section {
              HStack {
                Text("Apply ")
                TextField("", value: $settings.times, formatter: timesFormatter)
                .frame(width: 40)
                .multilineTextAlignment(.trailing)
                Text(" times per image")
              }
            }
            Divider()
            Section(
              header: Text("Background options")
            ) {
              HStack {
                Button("Backgrounds folder…") {
                  let panel = NSOpenPanel()
                  panel.canChooseFiles = false
                  panel.canChooseDirectories = true
                  panel.resolvesAliases = true
                  panel.allowsMultipleSelection = false
                  panel.isAccessoryViewDisclosed = false
                  let result = panel.runModal()
                  guard result == .OK, let url = panel.url else {
                    return
                  }
                  self.settings.backgrounds = url
                }
                if settings.backgrounds == nil {
                  Text("-")
                } else {
                  Button("X") {
                    self.settings.backgrounds = nil
                  }
                  Text("\(settings.backgrounds!.path)")
                  .truncationMode(.middle)
                }
              }
            }
            Divider()
            Section() {
              HStack {
                Text("Filter name")
                .frame(width: 100, alignment: .leading)
                Text("Exclude")
              }
              ForEach(Operation.allCases) { op in
                HStack {
                  Text("\(op.rawValue.capitalized)")
                  .frame(width: 100)
                  Toggle("", isOn: self.makeBinding(op))
                  Spacer()
                }
              }
            }
          }
          Spacer()
        }
        .frame(maxWidth: .infinity)
      }
      HStack {
        Spacer()
        Button("Generate \(totalSynthetics) images") {
          withAnimation {
            self.appData.navigation.currentModal = nil
          }
          DispatchQueue.main.async {
            self.appData.generateSynthetics()
          }
        }
        Button("Close") {
          withAnimation {
            self.appData.navigation.currentModal = nil
          }
        }
      }
    }
    .padding()
    .frame(minWidth: 300, maxWidth: 600, minHeight: 300, maxHeight: 600)
    .background(Color(NSColor.windowBackgroundColor))
    .border(Color(NSColor.separatorColor), width: 1)
    .padding([.horizontal, .bottom])
  }
}

struct SyntheticsModal_Previews: PreviewProvider {
  static var previews: some View {
    SyntheticsModal(settings: .constant(WorkspaceSettings()))
  }
}
