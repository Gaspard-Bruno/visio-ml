import SwiftUI

struct ImageRow: View {
  
  @ObservedObject var appData = AppData.shared
  let annotatedImage: AnnotatedImage

  private var isSelectedBinding: Binding<Bool> {
    Binding<Bool>(
      get: {
        self.annotatedImage.isMarked
      },
      set: { _ in
        self.appData.toggleImage(self.annotatedImage)
      }
    )
  }

  var body: some View {
    HStack {
      Toggle("", isOn: isSelectedBinding)
      Image(nsImage: NSImage(byReferencing: annotatedImage.url))
        .resizable()
        .aspectRatio(contentMode: .fit)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.vertical, 8)
    }
    .padding(.leading)
    .background(
      annotatedImage.isActive
      ? Color(NSColor.selectedTextBackgroundColor)
      : Color(NSColor.windowBackgroundColor)
    )
    .foregroundColor(
      !annotatedImage.isEnabled
      ? Color(NSColor.disabledControlTextColor)
      : annotatedImage.isActive
      ? Color(NSColor.selectedTextColor)
      : Color(NSColor.textColor)
    )
    .onTapGesture {
      guard self.annotatedImage.isEnabled else {
        return
      }
      self.appData.activateImage(self.annotatedImage)
    }
    .environment(\.isEnabled, annotatedImage.isEnabled)
  }
}

struct ImageItem_Previews: PreviewProvider {
  static var previews: some View {
    ImageRow(annotatedImage: AnnotatedImage(url: URL(string: "")!))
  }
}
