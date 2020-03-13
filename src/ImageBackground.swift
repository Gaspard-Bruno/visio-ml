import SwiftUI

struct ImageBackground: View {
  var body: some View {
    Image("samples/cat-and-dog")
    .resizable()
    .aspectRatio(contentMode: .fit)
  }
}


struct ImageBackground_Previews: PreviewProvider {
  static var previews: some View {
    ImageBackground()
  }
}
