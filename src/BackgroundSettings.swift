import SwiftUI

struct BackgroundSettings: View {

  @EnvironmentObject var store: DataStore
  @State var dropping = false
  
  var backgrounds: [URL] {
    store.workspace.backgrounds
  }
  
  var body: some View {
    ScrollView(.vertical) {
      VStack {
        VStack {
          Toggle("Randomize position (experimental)", isOn: $store.workspace.randomBgPosition)
        }
        .padding()

        if dropping || backgrounds.count == 0 {
          VStack {
            Spacer()
            Text("Drop background files into this area.")
            Spacer()
          }
          .padding()
        } else {
          ForEach(backgrounds, id: \.self) { bg in
            HStack {
              Text("\(bg.lastPathComponent)")
              Spacer()
              Button("Delete") {
                self.store.workspace.removeBackground(bg)
                DispatchQueue.main.async {
                  self.store.dummyToggle.toggle()
                }
              }
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
            self.store.workspace.addBackground(url)
          }
        }
      }
      DispatchQueue.main.async {
        self.store.dummyToggle.toggle()
      }
      return true
    }
  }
}


struct BackgroundSettings_Previews: PreviewProvider {
  static var previews: some View {
    BackgroundSettings()
    .environmentObject(DataStore())
  }
}
