import SwiftUI

struct ImageViewer: View {

  @State var start: CGPoint!
  @State var size: CGSize?
  @EnvironmentObject var dataStore: DataStore

  var labels: some View {
    ForEach(self.dataStore.annotatedImage!.annotation) { i in
      LabelOverlay(label: i)
      .onTapGesture {
        self.dataStore.selected = i
      }
    }
  }
  
  var dragLabel: some View {
    Group {
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

  var body: some View {
    GeometryReader { p in
      ZStack(alignment: .topLeading) {
        ImageBackground(image: self.dataStore.selectedImage, p: p)
        .gesture(
          DragGesture(minimumDistance: 0, coordinateSpace: .named("image"))
          .onChanged {
            guard let start = self.start else {
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
            let scale = self.dataStore.selectedImage.currentScale
            self.dataStore.annotatedImage!.annotation.append(
              LabelModel(label: "Untitled \(self.dataStore.counter)", coordinates: LabelModel.CoordinatesModel(y: start.y, x: start.x, height: size.height, width: size.width, scale: scale))
            )
            self.start = nil
            self.size = nil
          }
        )
        self.labels
        self.dragLabel
      }
    }
  }
}

struct ImageViewer_Previews: PreviewProvider {
  static var previews: some View {
    ImageViewer()
  }
}
