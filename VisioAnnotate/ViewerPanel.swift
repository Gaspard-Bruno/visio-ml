//
//  ViewerPanel.swift
//  VisioAnnotate
//
//  Created by dl on 2020-07-02.
//  Copyright © 2020 Gaspard+Bruno. All rights reserved.
//

import SwiftUI

struct ViewerPanel: View {
  
  @ObservedObject var appData = AppData.shared

  var body: some View {
    VStack(spacing: 0) {
      if appData.workingFolder == nil {
        VStack {
          Text("Please select a working folder to begin.")
          OpenButton()
        }
      } else if appData.activeImage != nil {
        ImageViewer(image: $appData.annotatedImages[appData.activeImageIndex!], scaleFactor: appData.currentScaleFactor!)
      } else {
        Text("No image selected")
        .foregroundColor(.secondary)
      }
    }
    .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
    .background(Color(NSColor.textBackgroundColor))
  }
}

struct ViewerPanel_Previews: PreviewProvider {
  static var previews: some View {
    ViewerPanel()
  }
}
