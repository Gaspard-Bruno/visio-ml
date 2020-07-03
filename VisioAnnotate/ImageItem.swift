//
//  ImageItem.swift
//  VisioAnnotate
//
//  Created by dl on 2020-07-01.
//  Copyright © 2020 Gaspard+Bruno. All rights reserved.
//

import SwiftUI

struct ImageRow: View {
  
  let annotatedImage: AnnotatedImage

  var body: some View {
    Text("\(annotatedImage.id)")
  }
}

struct ImageItem_Previews: PreviewProvider {
  static var previews: some View {
    ImageRow(annotatedImage: AnnotatedImage(id: "MyImage.png"))
  }
}
