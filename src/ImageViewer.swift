import SwiftUI

struct ImageViewer: View {

  @State var start: CGPoint!
  @State var size: CGSize?
  @EnvironmentObject var dataStore: DataStore

  var annotatedImage: AnnotatedImageModel {
    dataStore.selectedAnnotatedImage!
  }

  var selectedImage: ImageModel {
    dataStore.selectedImage!
  }

  var labels: some View {
    ForEach(self.dataStore.selectedAnnotatedImage!.annotation) { i in
      LabelOverlay(label: i)
      .onTapGesture {
        self.dataStore.selectedLabel = i
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
  
  func updateRect(_ value: DragGesture.Value) {
    guard let start = self.start else {
      self.start = value.startLocation
      return
    }
    let end = value.location
    size = CGSize(width: end.x - start.x, height: end.y - start.y)
  }

  func createLabel(_ value: DragGesture.Value) {
    guard let start = start, let size = size else {
      return
    }
    
    let x = size.width < 0 ? value.location.x : start.x
    let y = size.height < 0 ? value.location.y : start.y
    let width = abs(size.width)
    let height = abs(size.height)
    
    dataStore.counter += 1
    let scale = selectedImage.currentScale
    let label = LabelModel(label: "Untitled \(dataStore.counter)", coordinates: LabelModel.CoordinatesModel(y: y, x: x, height: height, width: width, scale: scale))
    dataStore.selectedAnnotatedImage!.annotation.append(label)
    dataStore.selectedLabel = annotatedImage.annotation.last
    self.start = nil
    self.size = nil
  }

  var body: some View {
    GeometryReader { p in
      ZStack(alignment: .topLeading) {
        ImageBackground(image: self.selectedImage, p: p)
        .gesture(
          DragGesture(minimumDistance: 0, coordinateSpace: .named("image"))
          .onChanged(self.updateRect)
          .onEnded(self.createLabel)
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
