//
//  InpectorPanel.swift
//  VisioAnnotate
//
//  Created by dl on 2020-07-02.
//  Copyright © 2020 Gaspard+Bruno. All rights reserved.
//

import SwiftUI

struct InspectorTab: View {

  let label: LocalizedStringKey
  let inspector: String
  @Binding var selection: String

  var body: some View {
    Text(label)
    .padding(.horizontal)
    .padding(.vertical, 8)
    .background(
      Color(NSColor.controlHighlightColor)
    )
    .foregroundColor(
      selection == inspector
      ? Color(NSColor.controlAccentColor)
      : Color(NSColor.controlTextColor)
    )
    .border(Color(NSColor.separatorColor), width: 1)
    .onTapGesture {
      self.selection = self.inspector
    }
  }
}

struct InspectorPanel: View {

  @State var currentInspector = "annotation"

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        InspectorTab(label: "Annotation", inspector: "annotation", selection: $currentInspector)
        InspectorTab(label: "Image", inspector: "image", selection: $currentInspector)
      }
      .padding(.top, 8)
      .fixedSize()
      Group {
        if currentInspector == "annotation" {
          AnnotationInspector()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if currentInspector == "image" {
          ImageInspector()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
      
    }
    .frame(maxWidth: 200, maxHeight: .infinity)
    .background(Color(NSColor.windowBackgroundColor))
  }
}

struct InpectorPanel_Previews: PreviewProvider {
  static var previews: some View {
    InspectorPanel()
  }
}
