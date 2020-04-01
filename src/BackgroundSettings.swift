import SwiftUI

struct BackgroundSettings: View {

  @EnvironmentObject var store: DataStore
  @State var dropping = false
  
  @State var images: [ImageModel] = []
  
  var image: ImageModel! {
    store.selectedImage
  }

  var inspector: some View {
    ScrollView(.vertical) {
      VStack {
        //TextField("Image name", text: $store.annotatedImage!.imagefilename)
        Text("\(store.selectedImage!.filename)")
        .padding()
        Divider()
        if dropping || store.images.count == 0 {
          Color.clear
          .overlay(
            Text("Drop background files into this area.")
          )
        } else {
          ForEach(images) { img in
            HStack {
              Text("\(img.filename)")
              Spacer()
              Button("Delete") {
                self.images.removeAll {
                  $0 == img
                }
              }
            }
          }
          Divider()
          Button("Generate now") {
            for i in self.images {
              self.store.applyBackground(i)
            }
          }
        }
      }
    }
    .onDrop(of: ["public.file-url"], isTargeted: $dropping) {
      for itemProvider in $0 {
        itemProvider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
          DispatchQueue.main.async {
            guard let urlData = urlData as? Data else {
              return
            }
            let url = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
            self.images.append(ImageModel(url: url))
          }
        }
      }
      return true
    }
  }
  var body: some View {
    Group {
      if image == nil {
        Text("Please add/select an image.")
      } else {
        inspector
      }
    }
  }
}


struct BackgroundSettings_Previews: PreviewProvider {
  static var previews: some View {
    BackgroundSettings()
    .environmentObject(DataStore())
  }
}
