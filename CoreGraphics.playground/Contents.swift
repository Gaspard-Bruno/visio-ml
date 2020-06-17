import CoreImage
import CoreGraphics
import AppKit
import SwiftUI
import PlaygroundSupport

extension Image {
  init(_ ciImage: CIImage) {
    let rep = NSCIImageRep(ciImage: ciImage)
    let nsImage = NSImage(size: rep.size)
    nsImage.addRepresentation(rep)
    self.init(nsImage: nsImage)
  }
}

extension CIImage {
  func rotateInPlace(angle a: CGFloat) -> CIImage {
    let rotateTransform = CGAffineTransform(rotationAngle: a)
    let offset = self.extent.applying(rotateTransform).pixelRound.origin
    let translateTransform = CGAffineTransform(translationX: -offset.x, y: -offset.y)
    let rotateAndTranslate = rotateTransform.concatenating(translateTransform)
    return self.transformed(by: rotateAndTranslate)
  }
}

extension CGAffineTransform {
  init(rotationAngle a: CGFloat, center: CGPoint) {
    let x = center.x
    let y = center.y
    self.init(a: cos(a), b: sin(a), c: -sin(a), d: cos(a), tx: x - x * cos(a) + y * sin(a), ty: y - x * sin(a) - y * cos(a))
  }
}

extension CGFloat {
  var pixelRound: CGFloat {
    self.rounded(.awayFromZero)
  }
}

extension CGPoint {
  var pixelRound: CGPoint {
    .init(x: self.x.pixelRound, y: self.y.pixelRound)
  }
}

extension CGSize {
  var pixelRound: CGSize {
    .init(width: self.width.pixelRound, height: self.height.pixelRound)
  }
}

extension CGRect {

  func reframe(source: CGRect, target: CGRect) -> CGRect {
    let adjustX = (target.size.width - source.size.width) / 2
    let adjustY = (target.size.height - source.size.height) / 2
    return self.applying(.init(translationX: adjustX.pixelRound, y: adjustY.pixelRound))
  }

  var pixelRound: CGRect {
    .init(
      origin: self.origin.pixelRound,
      size: self.size.pixelRound
    )
  }
}

let turtle = CIImage(contentsOf: Bundle.main.url(forResource: "BlueTurtle", withExtension: "png")!)!

let foot = CGRect(x: 75, y: 25, width: 30, height: 30)
// We are using the default coordinate system here

let bg = CIImage(contentsOf: Bundle.main.url(forResource: "RiverPalm", withExtension: "png")!)!

let scaleTransform = CGAffineTransform(scaleX: 1.5, y: 1.5)

let a = CGFloat.pi / 2
let turtleCenter = CGPoint(x: turtle.extent.midX, y: turtle.extent.midY)
let rotateTransform = CGAffineTransform(rotationAngle: a, center: turtleCenter)

// let rotateTransform = CGAffineTransform(a: cos(a), b: sin(a), c: -sin(a), d: cos(a), tx: x - x * cos(a) + y * sin(a), ty: y - x * sin(a) - y * cos(a))

let scaledTurtle = turtle.transformed(by: scaleTransform)
let scaledFoot = foot.applying(scaleTransform)

let rotatedTurtle = turtle.rotateInPlace(angle: a) // turtle.transformed(by: rotateTransform)
let rotatedFoot = foot.applying(rotateTransform).pixelRound.reframe(source: turtle.extent, target: rotatedTurtle.extent)

let scaledRotatedTurtle = rotatedTurtle.transformed(by: scaleTransform)
let scaledRotatedFoot = rotatedFoot.applying(scaleTransform).pixelRound

let scaledTurtleCenter = CGPoint(x: scaledTurtle.extent.midX, y: scaledTurtle.extent.midY)
let rotateTransform2 = CGAffineTransform(rotationAngle: a, center: scaledTurtleCenter)

let rotatedScaledTurtle = scaledTurtle.rotateInPlace(angle: a)
let rotatedScaledFoot = scaledFoot.applying(rotateTransform2).pixelRound.reframe(source: scaledTurtle.extent, target: rotatedScaledTurtle.extent)

turtle.extent
scaledTurtle.extent
scaledRotatedTurtle.extent
rotatedScaledTurtle.extent

struct Viewer: View {

  var image: CIImage
  var annotation: CGRect

  var body: some View {
    ZStack(
      alignment: .bottomLeading
      // Trying to replicate macOS's coordinate system
    ) {
      Color.white
      Image(image)
      Color.red
      .opacity(0.5)
      .frame(width: annotation.size.width, height: annotation.size.height)
      .offset(
        // Offset instead of possition because the latter focuses on the center
        x: annotation.origin.x,
        // SwiftUI flips the coordinate system vertically
        y: -annotation.origin.y
      )
    }
    .scaleEffect(0.5)
    .fixedSize()
  }
}

// How we render this in SwiftUI


let root = Group {
  Viewer(image: turtle, annotation: foot)
  Viewer(image: scaledTurtle, annotation: scaledFoot)
  Viewer(image: rotatedTurtle, annotation: rotatedFoot)
  Viewer(image: scaledRotatedTurtle, annotation: scaledRotatedFoot)
  Viewer(image: rotatedScaledTurtle, annotation: rotatedScaledFoot)
}

// Present the view in Playground
PlaygroundPage.current.liveView = NSHostingController(rootView: root)

