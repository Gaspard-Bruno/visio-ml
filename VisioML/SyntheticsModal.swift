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
    Operation.validCombinations.excluding(operations: settings.excludeOperations)
  }

  var totalSynthetics: Int {
    count * settings.times * filteredCombinations.count
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

  var numberOfTimesBinding: Binding<String> {
    .init(
      get: {
        "\(self.settings.times)"
      },
      set: {
        guard let times = Int($0) else {
          return
        }
        self.settings.times = times
      }
    )
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
                TextField("N", text: numberOfTimesBinding)
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
            Section(header: Text("Filter operations")) {
              HStack {
                Spacer()
                HStack {
                  Spacer()
                  Text("Filter")
                  .bold()
                  Spacer()
                }
                .frame(width: 200)
                Spacer()
                HStack {
                  Text("Exclude")
                  .bold()
                }
                .frame(width: 100)
                Spacer()
              }
              .padding()
              ForEach(Operation.allCases) { op in
                HStack {
                  Spacer()
                  HStack {
                    Text("\(op.rawValue.capitalized)")
                    Spacer()
                  }
                  .frame(width: 200)
                  Spacer()
                  HStack {
                    Toggle("", isOn: self.makeBinding(op))
                  }
                  .frame(width: 100)
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
        .environment(\.isEnabled, totalSynthetics > 0)
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
