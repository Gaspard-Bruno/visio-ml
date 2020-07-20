import CoreImage
import CoreGraphics
import SwiftUI

extension Image {
  init(_ ciImage: CIImage) {
    let rep = NSCIImageRep(ciImage: ciImage)
    let nsImage = NSImage(size: rep.size)
    nsImage.addRepresentation(rep)
    self.init(nsImage: nsImage)
  }
}
