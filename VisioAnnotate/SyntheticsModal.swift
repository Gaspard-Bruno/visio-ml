//
//  SyntheticsModal.swift
//  VisioAnnotate
//
//  Created by dl on 2020-07-02.
//  Copyright © 2020 Gaspard+Bruno. All rights reserved.
//

import SwiftUI

struct SyntheticsModal: View {

  @ObservedObject var appData = AppData.shared

  var body: some View {
    VStack {
      Text("Synthetic image generator")
      Spacer()
      HStack {
        Spacer()
        Button("Generate") {
        
        }
        Button("Close") {
          withAnimation {
            self.appData.currentModal = nil
          }
        }
      }
    }
    .padding()
    .frame(minWidth: 200, maxWidth: 300, minHeight: 200, maxHeight: 400)
    .background(Color(NSColor.windowBackgroundColor))
    .border(Color(NSColor.separatorColor), width: 1)
    .padding([.horizontal, .bottom])
  }
}

struct SyntheticsModal_Previews: PreviewProvider {
  static var previews: some View {
    SyntheticsModal()
  }
}
