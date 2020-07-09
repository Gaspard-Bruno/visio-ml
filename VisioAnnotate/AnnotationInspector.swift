//
//  AnnotationInspector.swift
//  VisioAnnotate
//
//  Created by dl on 2020-07-02.
//  Copyright © 2020 Gaspard+Bruno. All rights reserved.
//

import SwiftUI

struct AnnotationInspector: View {

  @Binding var annotations: [Annotation]
  @ObservedObject var appData = AppData.shared

  var imagePresent: Bool {
    appData.activeImage != nil
  }

  var annotationsPresent: Bool {
    imagePresent && annotations.count > 0
  }

  var annotationSelected: Bool {
    annotations.hasSelected
  }

  var annotation: Annotation {
    annotations[annotations.selectedIndex]
  }

  var annotationBody: some View {
    VStack(alignment: .leading) {
      Text("\(annotation.label)")
      Divider()
      TextField(annotation.label, text: $annotations[annotations.selectedIndex].label)
      Divider()
      Group {
        Text("X: \(annotation.coordinates.origin.x, specifier: "%.2f")")
        Text("Y: \(annotation.coordinates.origin.y, specifier: "%.2f")")
        Text("Width: \(annotation.width, specifier: "%.2f")")
        Text("Height: \(annotation.height, specifier: "%.2f")")
      }
      Divider()
      Button("Remove") {
        self.annotations.removeSelectedAnnotation()
      }
      Spacer()
      Text("\(annotations.count) annotations total")
    }
    .padding()
  }

  var body: some View {
    VStack(alignment: .leading) {
      if !annotationsPresent {
        Text("Create an annotation by dragging ontop of the image")
        .foregroundColor(.secondary)
        .padding()
        Spacer()
      } else if !annotationSelected {
        Text("Select an annotation to view/edit details")
        .foregroundColor(.secondary)
        .padding()
        Spacer()
      } else {
        annotationBody
      }
    }
  }
}

struct AnnotationInspector_Previews: PreviewProvider {
  static var previews: some View {
    AnnotationInspector(annotations: .constant([Annotation]()))
  }
}
