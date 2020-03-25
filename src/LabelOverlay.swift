import SwiftUI

struct LabelOverlay: View {

  var label: LabelModel
  @EnvironmentObject var dataStore: DataStore

  var selected: Bool {
    dataStore.selectedLabel == label
  }

  var color: Color {
    Color(selected ? "labelOverlay" : "labelOverlaySelected")
  }

  var scale: CGFloat! {
    dataStore.currentScaleFactor
  }

  var width: CGFloat {
    label.coordinates.width * scale
  }
  
  var height: CGFloat {
    label.coordinates.height * scale
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
    .alignmentGuide(.leading) { $0[.leading] }
    .alignmentGuide(.top) { $0[.top] }
    .offset(x: label.coordinates.x * scale, y: label.coordinates.y * scale)
  }
}

struct LabelOverlay_Previews: PreviewProvider {
  static var previews: some View {
    LabelOverlay(label: LabelModel.specimen)
    .environmentObject(DataStore())
    .previewLayout(.sizeThatFits)
  }
}
