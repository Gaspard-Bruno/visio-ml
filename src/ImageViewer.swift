import SwiftUI

struct ImageViewer: View {

  @State var start: CGPoint!
  @State var size: CGSize?
  @EnvironmentObject var dataStore: DataStore

  var body: some View {
    ZStack(alignment: .topLeading) {
      ImageBackground(image: dataStore.selectedImage)
      .gesture(
        DragGesture(minimumDistance: 0, coordinateSpace: .named("image"))
        .onChanged {
          guard let start = self.start else {
            print("\($0.startLocation)")
            self.start = $0.startLocation
            return
          }
          let end = $0.location
          self.size = CGSize(width: end.x - start.x, height: end.y - start.y)
        }
        .onEnded { _ in
          guard let start = self.start, let size = self.size else {
            return
          }
          self.dataStore.counter += 1
          self.dataStore.annotatedImage.annotation.append(
            LabelModel(label: "Untitled \(self.dataStore.counter)", coordinates: LabelModel.CoordinatesModel(y: start.y, x: start.x, height: size.height, width: size.width))
          )
          self.start = nil
          self.size = nil
        }
      )

      ForEach(dataStore.annotatedImage.annotation) { i in
        LabelOverlay(label: i)
        .onTapGesture {
          self.dataStore.selected = i
        }
      }

      if start != nil && size != nil {
        Color.blue
        .frame(width: size!.width, height: size!.height)
        .alignmentGuide(.leading) { $0[.leading] }
        .alignmentGuide(.top) { $0[.top] }
        .offset(x: start.x, y: start.y)
        .opacity(0.5)
      }
    }
  }
}

struct ImageViewer_Previews: PreviewProvider {
  static var previews: some View {
    ImageViewer()
  }
}
