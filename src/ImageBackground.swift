import SwiftUI

struct ImageBackground: View {
  
  var image: ImageModel
  var p: GeometryProxy
  
  var body: some View {
    Image(nsImage: NSImage(byReferencing: image.url))
    .resizable()
    .aspectRatio(contentMode: .fit)
    .anchorPreference(
      key: ImageSizePrefKey.self,
      value: .bounds,
      transform: {
        self.p[$0].size
      }
    )
    .background(Color("selectedBackground"))
    .border(Color.accentColor, width: 1)
  }
}


struct ImageBackground_Previews: PreviewProvider {
  static var previews: some View {
    GeometryReader {
      ImageBackground(image: ImageModel.specimen, p: $0)
    }
  }
}
