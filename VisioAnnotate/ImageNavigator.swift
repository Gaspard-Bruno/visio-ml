//
//  ImageNavigator.swift
//  VisioAnnotate
//
//  Created by dl on 2020-07-01.
//  Copyright © 2020 Gaspard+Bruno. All rights reserved.
//

import SwiftUI

struct ImageNavigator: View {

  @ObservedObject var appData = AppData.shared

  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        ForEach(appData.annotatedImages) {
          ImageRow(annotatedImage: $0)
        }
        Spacer()
      }
    }
    .frame(minWidth: 80, maxWidth: 200, maxHeight: .infinity)
    .background(Color(NSColor.windowBackgroundColor))
    .background(KeyboardHandler())
    .transition(.asymmetric(insertion: .slide, removal: .move(edge: .leading)))

  }
}

struct ImageList_Previews: PreviewProvider {
  static var previews: some View {
    ImageNavigator()
  }
}
