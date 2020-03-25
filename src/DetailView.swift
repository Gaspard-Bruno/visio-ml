import SwiftUI

struct DetailView: View {

  var body: some View {
    HStack {
      ImageViewer()
      .padding()
      Divider()
      SidePanel()
      .frame(minWidth: 150, maxWidth: 300)
      .padding()
    }
  }
}


struct DetailView_Previews: PreviewProvider {
  static var previews: some View {
    DetailView()
  }
}
