import SwiftUI
import CoreImage

struct ImageInspector: View {

  let activeImage: AnnotatedImage?
  let scaledSize: CGSize

  var imagePresent: Bool {
    activeImage != nil && activeImage!.fileExists
  }

  var image: AnnotatedImage {
    activeImage!
  }
  
  var imageSize: CGSize {
    CIImage(contentsOf: image.url)!.extent.size
  }

  var currentScaleFactor: CGFloat {
    scaledSize.width / imageSize.width
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      if imagePresent {
        Text("\(image.shortName)")
        Divider()
        Text("Width: \(imageSize.width, specifier: "%.2f")")
        Text("Height: \(imageSize.height, specifier: "%.2f")")
        Divider()
        Text("Scaled width: \(scaledSize.width, specifier: "%.2f")")
        Text("Scaled height: \(scaledSize.height, specifier: "%.2f")")
        Text("Scale factor: \(currentScaleFactor, specifier: "%.3f")")
        Spacer()
      } else if activeImage != nil {
        Text("No image selected")
        .foregroundColor(.secondary)
      } else {
        Text("Image missing from file system")
        .foregroundColor(.secondary)
      }
    }
    .padding()
  }
}

struct ImageInspector_Previews: PreviewProvider {
  static var previews: some View {
    ImageInspector(activeImage: nil, scaledSize: .zero)
  }
}
