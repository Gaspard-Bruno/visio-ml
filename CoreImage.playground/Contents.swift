//: Experiment with core image and coordinate systems

import AppKit
import PlaygroundSupport
import SwiftUI
import CoreImage

func ciImageSize(_ ciImage: CIImage) -> CGSize { ciImage.extent.size }

func makeOffset(imageSize: CGSize, annotation: CGRect) -> CGSize {
  CGSize(width: annotation.origin.x - annotation.size.width / 2, height: -(imageSize.height - annotation.origin.y - annotation.size.height / 2))
}

func makeAnnotationTransform(_ transform: CGAffineTransform) -> CGAffineTransform {
  // CGAffineTransform(translationX: transform.tx, y: -transform.ty)
  var newTransform = transform
  newTransform.ty = -transform.ty
  return newTransform
}

func moveAnnotation(_ annotation: CGRect, from : CGSize, to: CGSize) -> CGRect {
  CGRect(
    origin: CGPoint(
      x: annotation.origin.x,
      y: annotation.origin.y + (to.height - from.height)
    ),
    size: annotation.size
  )
}

// Turtle

let blueTurtleUrl = Bundle.main.url(forResource: "BlueTurtle", withExtension: "png")!
let blueTurtle = CIImage(contentsOf: blueTurtleUrl)!

// Annotation: center; from the top-left
let footAnnotation = CGRect(x: 87, y: 220, width: 35, height: 35)
let turtleSize = ciImageSize(blueTurtle)

// Background

let riverPalmUrl = Bundle.main.url(forResource: "RiverPalm", withExtension: "png")!
let riverPalm = CIImage(contentsOf: riverPalmUrl)!

let bgSize = ciImageSize(riverPalm)

let scaleTransform = CGAffineTransform(scaleX: 1.25, y: 0.75)
let scaledSize = turtleSize.applying(scaleTransform)

let maxTranslationX = bgSize.width - scaledSize.width
let maxTranslationY = bgSize.height - scaledSize.height

let translateTransform = CGAffineTransform(translationX: maxTranslationX, y: maxTranslationY)


let transform = scaleTransform.concatenating(translateTransform)

let transformedTurtle = blueTurtle.transformed(by: transform)
let turtleOverBg = transformedTurtle.composited(over: riverPalm)

let scaledAnnotation = footAnnotation.applying(scaleTransform)

let transformedAnnotation = moveAnnotation(scaledAnnotation, from: scaledSize, to: bgSize).applying(makeAnnotationTransform(translateTransform))


let coloredNoise = CIFilter(name:"CIRandomGenerator")!
let noiseImage = coloredNoise.outputImage!
let whitenVector = CIVector(x: 0, y: 1, z: 0, w: 0)
let fineGrain = CIVector(x:0, y:0.005, z:0, w:0)
let zeroVector = CIVector(x: 0, y: 0, z: 0, w: 0)
let whiteningFilter = CIFilter(name:"CIColorMatrix",
   parameters: [
      kCIInputImageKey: noiseImage,
      "inputRVector": whitenVector,
      "inputGVector": whitenVector,
      "inputBVector": whitenVector,
      "inputAVector": fineGrain,
      "inputBiasVector": zeroVector
    ])!
let whiteSpecks = whiteningFilter.outputImage!
let speckCompositor = CIFilter(name:"CISourceOverCompositing",
    parameters: [
      kCIInputImageKey: whiteSpecks,
      kCIInputBackgroundImageKey: turtleOverBg
    ]
)!
let speckledImage = speckCompositor.outputImage!
let verticalScale = CGAffineTransform(scaleX: 1.5, y: 25)
let transformedNoise = noiseImage.transformed(by: verticalScale)
let darkenVector = CIVector(x: 4, y: 0, z: 0, w: 0)
let darkenBias = CIVector(x: 0, y: 1, z: 1, w: 1)
let darkeningFilter = CIFilter(name:"CIColorMatrix",
  parameters: [
    kCIInputImageKey: transformedNoise,
    "inputRVector": darkenVector,
    "inputGVector": zeroVector,
    "inputBVector": zeroVector,
    "inputAVector": zeroVector,
    "inputBiasVector": darkenBias
  ])!
let randomScratches = darkeningFilter.outputImage!

let grayscaleFilter = CIFilter(name:"CIMinimumComponent",
   parameters:
    [
        kCIInputImageKey: randomScratches
    ])!
let darkScratches = grayscaleFilter.outputImage!

    let oldFilmCompositor = CIFilter(name:"CIMultiplyCompositing",
     parameters:
    [
        kCIInputImageKey: darkScratches,
        kCIInputBackgroundImageKey: speckledImage
    ])!
    let oldFilmImage = oldFilmCompositor.outputImage!

let finalImage = oldFilmImage.cropped(to: turtleOverBg.extent)


let image = finalImage
let annotation = transformedAnnotation

// Offset: bottom-left corner; from the top-left
let offset = makeOffset(imageSize: ciImageSize(image), annotation: annotation)

let rep = NSCIImageRep(ciImage: image)
let nsImage = NSImage(size: rep.size)
nsImage.addRepresentation(rep)

let root = ZStack(alignment: .bottomLeading) {
  Image(nsImage: nsImage)
  Color.red
  .opacity(0.5)
  .frame(width: annotation.size.width, height: annotation.size.height)
  .offset(offset)
}
.scaleEffect(0.5)


// Present the view in Playground
PlaygroundPage.current.liveView = NSHostingController(rootView: root)

