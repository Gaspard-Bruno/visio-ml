//
//  AnnotationInspector.swift
//  VisioAnnotate
//
//  Created by dl on 2020-07-02.
//  Copyright © 2020 Gaspard+Bruno. All rights reserved.
//

import SwiftUI

struct AnnotationInspector: View {

  @ObservedObject var appData = AppData.shared

  var imagePresent: Bool {
    appData.activeImage != nil
  }

  var image: AnnotatedImage {
    appData.activeImage!
  }

  var annotationsPresent: Bool {
    imagePresent && annotations.count > 0
  }

  var annotationSelected: Bool {
    annotationsPresent && image.hasActiveAnnotation
  }

  var annotation: Annotation {
    image.activeAnnotation
  }

  var annotations: [Annotation] {
    image.annotations
  }

  var annotationBody: some View {
    VStack(alignment: .leading) {
      Text("\(annotation.label)")
      Divider()
      Button("Remove") {
        // self.image.remove(annotation: annotation)
      }
      Spacer()
      Text("\(annotations.count) annotations total")
    }
    .padding()
  }

  var body: some View {
    VStack(alignment: .leading) {
      if !imagePresent {
        Text("Select an image from the navigator")
        .foregroundColor(.secondary)
      } else if !annotationsPresent {
        Text("Create an annotation by dragging ontop of the image")
        .foregroundColor(.secondary)
      } else if !annotationSelected {
        Text("Select an annotation to view/edit details")
        .foregroundColor(.secondary)
      } else {
        annotationBody
      }
    }
  }
}

struct AnnotationInspector_Previews: PreviewProvider {
  static var previews: some View {
    AnnotationInspector()
  }
}
