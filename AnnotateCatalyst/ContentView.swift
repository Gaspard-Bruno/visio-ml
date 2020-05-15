import SwiftUI

struct ContentView: View {

  @EnvironmentObject var userData: UserData

  @State var newAreaDrawing = false
  @State var newAreaCenter = CGPoint(x: 0, y: 0)
  @State var newAreaCorner = CGPoint(x: 0, y: 0)

  @State var areaMoving = false
  @State var movingAreaCenter = CGPoint(x: 0, y: 0)
  @State var movingAreaSize = CGSize(width: 0, height: 0)

  @State var areas: [CGRect] = []
  
  var newAreaSize: CGSize {
    CGSize(
      width: abs(newAreaCenter.x - newAreaCorner.x) * 2,
      height: abs(newAreaCenter.y - newAreaCorner.y) * 2
    )
  }
  
  var newArea: CGRect {
    CGRect(origin: newAreaCenter, size: newAreaSize)
  }
  
  var body: some View {
    VStack {
      Toolbar()
      HStack {
        list
        Spacer()
        if userData.isImageSelected {
          Text("No image selected")
        } else {
          viewer
          Spacer()
          info
        }
      }
      Spacer()
    }
  }

  var list: some View {
    VStack {
      ForEach(userData.images) { image in
        Text("\(image.id)")
        .onTapGesture {
          self.userData.selectImage(image.id)
        }
      }
      Spacer()
    }
    .frame(width: 100)
  }

  var viewer: some View {
    ZStack(alignment: .topLeading) {
      Image(systemName: userData.selectedImage.id)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 300)
      .gesture(
        DragGesture()
        .onChanged {
          if !self.newAreaDrawing {
            self.newAreaDrawing.toggle()
            self.newAreaCenter = $0.startLocation
          }
          self.newAreaCorner = $0.location
        }
        .onEnded { _ in
          self.userData.addArea(with: self.newArea)
          self.newAreaDrawing.toggle()
        }
      )

      Group {
        if newAreaDrawing {
          Rectangle()
          .foregroundColor(.blue)
          .opacity(0.5)
          .position(newAreaCenter)
          .frame(width: newAreaSize.width, height:  newAreaSize.height)
        }
        if areaMoving {
          Rectangle()
          .foregroundColor(.green)
          .opacity(0.5)
          .position(movingAreaCenter)
          .frame(width: movingAreaSize.width, height:  movingAreaSize.height)
        }
        ForEach(userData.selectedImage.areas) { area in
          Rectangle()
            .foregroundColor(.green)
            .opacity(area.isMoving ? 0.25 : 0.5)
            .position(area.rect.origin)
            .frame(width: area.rect.width, height:  area.rect.height)
            .gesture(
              DragGesture()
              .onChanged {
                if !self.areaMoving {
                  self.areaMoving.toggle()
                  self.userData.startMovingArea(area.id)
                  self.movingAreaSize = area.rect.size
                }
                self.movingAreaCenter = $0.location
              }
              .onEnded { _ in
                self.userData.moveArea(area.id, to: self.movingAreaCenter)
                self.areaMoving.toggle()
              }
            )
        }
      }
    }
    .border(Color.blue, width: 1)
  }
  
  var info: some View {
    VStack {
      if newAreaDrawing {
        Text("Center: (\(newAreaCenter.x), \(newAreaCenter.y))")
      } else {
        Text("Center not set")
      }
      Divider()
      ForEach(userData.selectedImage.areas) { area in
        Text("x: \(area.rect.origin.x, specifier: "%.0f")")
        Text("y: \(area.rect.origin.y, specifier: "%.0f")")
        Text("w: \(area.rect.size.width, specifier: "%.0f")")
        Text("h: \(area.rect.size.height, specifier: "%.0f")")
        Divider()
      }
    }
    .frame(width: 100)
  }

}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ContentView()
      ContentView(
        newAreaCenter: CGPoint(x: 150, y: 150),
        newAreaCorner: CGPoint(x: 20, y: 20)
      )
    }
    .environmentObject(UserData())
    .previewLayout(.sizeThatFits)
  }
}
