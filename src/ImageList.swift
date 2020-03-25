import SwiftUI

struct ImageList: View {
  
  @EnvironmentObject var store: DataStore
  @State var dropping = false
  
  var body: some View {
    Group {
      if dropping || store.images.count == 0 {
        Color("background")
        .overlay(
          Text("Drop image files into this area.")
        )
      } else {
        list
      }
    }
    .frame(minWidth: 225, maxWidth: 300)
    .onDrop(of: ["public.file-url"], isTargeted: $dropping) {
      for itemProvider in $0 {
        itemProvider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
          DispatchQueue.main.async {
            guard let urlData = urlData as? Data else {
              return
            }
            let url = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
            self.store.images.append(ImageModel(url: url))
            self.store.selectedImage = self.store.images.last!
          }
        }
      }
      return true
    }
  }
  
  var list: some View {
    VStack {
      List(selection: $store.selectedImage) {
        ForEach(store.images) {
          Text("\($0.filename)")
            .tag($0)
        }
      }
      .listStyle(SidebarListStyle())
      .onDeleteCommand {
        self.store.deleteSelectedImage()
      }
    }
  }
}


struct ImageList_Previews: PreviewProvider {
  static var previews: some View {
    ImageList()
  }
}
