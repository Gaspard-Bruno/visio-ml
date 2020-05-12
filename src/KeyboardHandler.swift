import SwiftUI

struct KeyboardHandler: NSViewRepresentable {

  @EnvironmentObject var store: DataStore

  class KeyView: NSView {
    var store: DataStore!

    override init(frame frameRect: NSRect) {
      super.init(frame: frameRect)
    }

    convenience init(_ store: DataStore) {
      self.init()
      self.store = store
    }
    
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
      if specialKey == .delete {
        self.store.deleteSelectedLabel()
      }
    }
  }
  
  func makeNSView(context: Context) -> NSView {
    let view = KeyView(store)
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
