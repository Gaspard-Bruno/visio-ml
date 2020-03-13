import SwiftUI

struct LabelOverlay: View {

  var label: LabelModel
  var selected: Bool

  var color: Color {
    Color(selected ? "labelOverlay" : "labelOverlaySelected")
  }

  var body: some View {
    VStack(alignment: .trailing, spacing: 0) {
      color
      .frame(width: label.coordinates.width, height: label.coordinates.height)
      .opacity(0.5)
      .border(color, width: 1)

      Text("\(label.label)")
      .font(.footnote)
      .foregroundColor(Color("labelOverlayText"))
      .background(color)
    }
    .alignmentGuide(.leading) { $0[.leading] }
    .alignmentGuide(.top) { $0[.top] }
    .offset(x: label.coordinates.x, y: label.coordinates.y)
  }
}

struct LabelOverlay_Previews: PreviewProvider {
  static var previews: some View {
    LabelOverlay(label: LabelModel.specimen, selected: true)
    .previewLayout(.sizeThatFits)
  }
}
