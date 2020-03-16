import SwiftUI

struct ImageList: View {
  
  @EnvironmentObject var dataStore: DataStore
  @State var dropping = false
  
  var body: some View {
    Group {
      if dropping {
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
            self.dataStore.images.append(ImageModel(url: url))
          }
        }
      }
      return true
    }
  }
  
  var list: some View {
    VStack {
      List(selection: $dataStore.selectedImage) {
        ForEach(dataStore.images) {
          Text("\($0.filename)")
            .tag($0)
        }
      }
      .listStyle(SidebarListStyle())
    }
  }
}


struct ImageList_Previews: PreviewProvider {
  static var previews: some View {
    ImageList()
  }
}
