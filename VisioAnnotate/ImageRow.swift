//
//  ImageItem.swift
//  VisioAnnotate
//
//  Created by dl on 2020-07-01.
//  Copyright © 2020 Gaspard+Bruno. All rights reserved.
//

import SwiftUI

struct ImageRow: View {
  
  @ObservedObject var appData = AppData.shared
  
  let annotatedImage: AnnotatedImage


  private var isSelectedBinding: Binding<Bool> {
    Binding<Bool>(
      get: {
        self.annotatedImage.isMarked
      },
      set: { _ in
        self.appData.toggleImage(self.annotatedImage)
      }
    )
  }

  var body: some View {
    HStack {
      Toggle("", isOn: isSelectedBinding)
      Text("\(annotatedImage.shortName)")
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.vertical, 8)
    }
    .padding(.leading)
    .background(
      annotatedImage.isActive
      ? Color(NSColor.selectedTextBackgroundColor)
      : Color(NSColor.windowBackgroundColor)
    )
    .foregroundColor(
      annotatedImage.isActive
      ? Color(NSColor.selectedTextColor)
      : Color(NSColor.textColor)
    )
    .onTapGesture {
      self.appData.activateImage(self.annotatedImage)
    }
  }
}

struct ImageItem_Previews: PreviewProvider {
  static var previews: some View {
    ImageRow(annotatedImage: AnnotatedImage(url: URL(string: "")!))
  }
}
