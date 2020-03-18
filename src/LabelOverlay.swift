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

  var scale: CGFloat {
    dataStore.selectedImage!.currentScale
  }

  var body: some View {
    VStack(alignment: .trailing, spacing: 0) {
      color
      .frame(width: label.coordinates.width * scale, height: label.coordinates.height * scale)
      .opacity(0.5)
      .border(color, width: 1)

      Text("\(label.label)")
      .font(.footnote)
      .foregroundColor(Color("labelOverlayText"))
      .background(color)
    }
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
