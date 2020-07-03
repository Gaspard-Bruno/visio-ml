//
//  StatusBar.swift
//  VisioAnnotate
//
//  Created by dl on 2020-07-02.
//  Copyright © 2020 Gaspard+Bruno. All rights reserved.
//

import SwiftUI

struct StatusBar: View {

  @ObservedObject var appData = AppData.shared

  var body: some View {
    HStack {
      if appData.workingFolder == nil {
        Text("Please open a working folder")
      } else if appData.annotatedImages.count == 0 {
        Text("Current working folder contains no images")
      } else {
        Text("\(appData.annotatedImages.count) images loaded")
      }
      Spacer()
    }
    .foregroundColor(.secondary)
    .padding(.horizontal)
    .frame(height: 40)
    .frame(maxWidth: .infinity)
    .background(Color(NSColor.windowBackgroundColor))
    .border(Color(NSColor.separatorColor), width: 1)
  }
}

struct StatusBar_Previews: PreviewProvider {
  static var previews: some View {
    StatusBar()
  }
}
