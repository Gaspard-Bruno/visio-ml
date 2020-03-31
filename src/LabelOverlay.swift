import SwiftUI

struct LabelOverlay: View {

  var label: LabelModel
  @EnvironmentObject var store: DataStore

  var selected: Bool {
    store.selectedLabel == label
  }

  var color: Color {
    Color(selected ? "labelOverlay" : "labelOverlaySelected")
  }

  var scale: CGFloat! {
    store.currentScaleFactor
  }

  var width: CGFloat {
    label.coordinates.width * scale
  }
  
  var height: CGFloat {
    label.coordinates.height * scale
  }

  var x: CGFloat {
    (label.coordinates.x - label.coordinates.width / 2) * scale
  }
  
  var y: CGFloat {
    (label.coordinates.y - label.coordinates.height / 2) * scale
  }

  var body: some View {
    VStack(alignment: .trailing, spacing: 0) {
      color
      .frame(width: width, height: height)
      .opacity(0.5)
      .border(color, width: 1)
    }
    .overlay(
      Text("\(label.label)")
      .lineLimit(1)
      .fixedSize()
      .font(.footnote)
      .foregroundColor(Color("labelOverlayText"))
      .background(color)
      .offset(x: width / 2, y: height / 2)
    )
    .offset(x: x, y: y)
  }
}

struct LabelOverlay_Previews: PreviewProvider {
  static var previews: some View {
    LabelOverlay(label: LabelModel.specimen)
    .environmentObject(DataStore())
    .previewLayout(.sizeThatFits)
  }
}
