import SwiftUI

struct ImageViewer: View {

  @State var start: CGPoint!
  @State var size: CGSize?
  @EnvironmentObject var store: DataStore

  var annotatedImage: ImageAnnotationModel! {
    store.selectedAnnotatedImage
  }

  var selectedImage: ImageModel! {
    store.selectedImage
  }

  var viewportSize: CGSize! {
    store.viewportSize
  }

  var labels: some View {
    ForEach(self.store.selectedAnnotatedImage!.annotation) { i in
      LabelOverlay(label: i)
      .onTapGesture {
        self.store.selectedLabel = i
      }
    }
  }
  
  var dragLabel: some View {
    Group {
      if start != nil && size != nil {
        Color.blue
        .frame(width: size!.width, height: size!.height)
        .offset(x: start.x - size!.width / 2, y: start.y - size!.height / 2)
        //.position(x: start.x, y: start.y)
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
    size = CGSize(width: (end.x - start.x) * 2, height: (end.y - start.y) * 2)
  }

  func createLabel(_ value: DragGesture.Value) {
    guard let start = start, let size = size else {
      return
    }
    
    let width = abs(size.width)
    let height = abs(size.height)
    let x = size.width < 0 ? value.location.x + width / 2 : start.x
    let y = size.height < 0 ? value.location.y + height / 2 : start.y

    // Find an available name
    var count = 0
    var name = ""
    repeat {
      count += 1
      name = "label_\(count)"
    } while (store.selectedAnnotatedImage!.annotation.first(where: { $0.label == name }) != nil)

    let scale = store.currentScaleFactor!
    
    let label = LabelModel(label: name, coordinates: LabelModel.CoordinatesModel(y: y, x: x, height: height, width: width, scale: scale))
    store.selectedAnnotatedImage!.annotation.append(label)
    store.selectedLabel = annotatedImage.annotation.last
    self.start = nil
    self.size = nil
  }
  
  func body(_ p: GeometryProxy) -> some View {
    ZStack(alignment: .topLeading) {
      ImageBackground(image: selectedImage, p: p)
      .gesture(
        DragGesture(minimumDistance: 0, coordinateSpace: .named("image"))
        .onChanged(updateRect)
        .onEnded(createLabel)
      )
      if viewportSize != nil {
        labels
      }
      dragLabel
    }
  }

  var body: some View {
    Group {
      if selectedImage != nil {
        GeometryReader { self.body($0) }
      }
    }
  }
}

struct ImageViewer_Previews: PreviewProvider {
  static var previews: some View {
    ImageViewer()
  }
}
