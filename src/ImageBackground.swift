import SwiftUI

struct ImageBackground: View {
  
  var image: ImageModel

  var body: some View {
    Image(nsImage: NSImage(byReferencing: image.url))
    .resizable()
    .aspectRatio(contentMode: .fit)
    .coordinateSpace(name: "image")
    .background(Color("selectedBackground"))
    .border(Color.accentColor, width: 1)
  }
}


struct ImageBackground_Previews: PreviewProvider {
  static var previews: some View {
    ImageBackground(image: ImageModel.specimen)
  }
}
