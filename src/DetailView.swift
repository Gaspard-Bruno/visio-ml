import SwiftUI

struct DetailView: View {

  @EnvironmentObject var dataStore: DataStore

  var body: some View {
    HStack {
      ImageViewer()
      .padding()
      Divider()
      SidePanel()
      .frame(minWidth: 150, maxWidth: 300)
      .padding()
    }
    .onPreferenceChange(ImageSizePrefKey.self) {
      guard let image = self.dataStore.selectedImage, let size = $0  else {
        return
      }
      image.currentScaledSize = size
      // HACK ALERT: this is needed to refresh ImageInfo
      DispatchQueue.main.async {
        self.dataStore.dummyToggle.toggle()
      }
    }
  }
}


struct DetailView_Previews: PreviewProvider {
  static var previews: some View {
    DetailView()
  }
}
