//
//  SyntheticsModal.swift
//  VisioAnnotate
//
//  Created by dl on 2020-07-02.
//  Copyright © 2020 Gaspard+Bruno. All rights reserved.
//

import SwiftUI

struct SyntheticsModal: View {

  @Binding var settings: SyntheticsSettings
  @ObservedObject var appData = AppData.shared
  
  @State var selectionOnly = false
  
  var count: Int {
    selectionOnly
    ? appData.annotatedImages.marked.count
    : appData.annotatedImages.count
  }

  var body: some View {
    VStack {
      Text("Synthetic image generator")
      ScrollView {
        VStack {
          Form {
          
            Section(
              header: Text("Selection"),
              footer: Text("Will apply to \(count) objets")
            ) {
              Toggle("Apply to marked images only", isOn: $selectionOnly)
            }
            Divider()

            Section(
              header: Text("Backgrounds")
            ) {
              Button("Select folder…") {
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
                Text("\(settings.backgrounds!.path)")
              }
              Toggle("Select background randomly", isOn: .constant(true))
            }

            Section(header: Text("Geometric Filters")) {
              Toggle("Flip", isOn: .constant(true))
              Toggle("Scale", isOn: .constant(true))
              Toggle("Rotate", isOn: .constant(true))
            }
            Section(header: Text("Effects")) {
              Toggle("Gaussian Blur", isOn: .constant(true))
              Toggle("Color Monochrome", isOn: .constant(true))
              Toggle("Emboss", isOn: .constant(true))
              Toggle("Noise", isOn: .constant(true))
            }
            Section(header: Text("Options")) {
              Toggle("Combine multiple filters", isOn: .constant(true))
              Toggle("Randomize parameters multiple times", isOn: .constant(true))
            }
            .environment(\.isEnabled, false)
          }
          Spacer()
        }
        .frame(maxWidth: .infinity)
      }
      HStack {
        Spacer()
        Button("Generate") {
          withAnimation {
            self.appData.currentModal = nil
          }
          DispatchQueue.main.async {
            self.appData.generateSynthetics(selectionOnly: self.selectionOnly)
          }
        }
        Button("Close") {
          withAnimation {
            self.appData.currentModal = nil
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
    SyntheticsModal(settings: .constant(SyntheticsSettings()))
  }
}
