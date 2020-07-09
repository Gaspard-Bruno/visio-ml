import SwiftUI

struct KeyboardHandler: NSViewRepresentable {

  class KeyView: NSView {

    override init(frame frameRect: NSRect) {
      super.init(frame: frameRect)
    }

    //  convenience init(_ store: DataStore) {
    //    self.init()
    //    self.store = store
    //  }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override var acceptsFirstResponder: Bool { true }
    
    override func keyDown(with event: NSEvent) {
      super.keyDown(with: event)
      guard let specialKey = event.specialKey else {
        self.nextResponder?.keyDown(with: event)
        return
      }
      switch specialKey {
      case .delete:
        AppData.shared.removeActiveAnnotation()
      case .upArrow:
        AppData.shared.activatePreviousImage()
      case .downArrow:
        AppData.shared.activateNextImage()
      default:
        print("No action")
      }
    }
  }
  
  func makeNSView(context: Context) -> NSView {
    let view = KeyView()
    DispatchQueue.main.async { // wait till next event cycle
      view.window?.makeFirstResponder(view)
    }
    return view
  }
  
  func updateNSView(_ nsView: NSView, context: Context) { }
}

struct KeyboardHandler_Previews: PreviewProvider {
  static var previews: some View {
    Text("Hello, World!").background(KeyboardHandler())
  }
}
