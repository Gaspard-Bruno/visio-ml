//
//  InpectorPanel.swift
//  VisioAnnotate
//
//  Created by dl on 2020-07-02.
//  Copyright © 2020 Gaspard+Bruno. All rights reserved.
//

import SwiftUI

struct InspectorPanel: View {
  var body: some View {
    Text("Inspector")
    .frame(minWidth: 50, maxWidth: 200, maxHeight: .infinity)
    .background(Color(NSColor.windowBackgroundColor))
  }
}

struct InpectorPanel_Previews: PreviewProvider {
  static var previews: some View {
    InspectorPanel()
  }
}
