//
//  ImageInspector.swift
//  VisioAnnotate
//
//  Created by dl on 2020-07-02.
//  Copyright © 2020 Gaspard+Bruno. All rights reserved.
//

import SwiftUI

struct ImageInspector: View {

  @ObservedObject var appData = AppData.shared

  var imagePresent: Bool {
    appData.activeImage != nil
  }

  var image: AnnotatedImage {
    appData.activeImage!
  }
  
  var imageSize: CGSize {
    image.ciImage.extent.size
  }
  
  var scaledSize: CGSize {
    appData.viewportSize
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      if imagePresent {
        Text("\(image.shortName)")
        Divider()
        Text("Width: \(imageSize.width, specifier: "%.2f")")
        Text("Height: \(imageSize.height, specifier: "%.2f")")
        Divider()
        Text("Scaled width: \(scaledSize.width, specifier: "%.2f")")
        Text("Scaled height: \(scaledSize.height, specifier: "%.2f")")
        Text("Scale factor: \(appData.currentScaleFactor!, specifier: "%.3f")")
        Spacer()
      } else {
        Text("No image present")
        .foregroundColor(.secondary)
      }
    }
    .padding()
  }
}

struct ImageInspector_Previews: PreviewProvider {
  static var previews: some View {
    ImageInspector()
  }
}
