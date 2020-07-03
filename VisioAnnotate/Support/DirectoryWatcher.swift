import Foundation

public class DirectoryWatcher : NSObject {

  deinit { stop() }
  
  public typealias Callback = () -> ()
  
  public convenience init?(_ url: URL, callback: @escaping Callback) {
    self.init()
    let path = url.path
    guard watch(path: path, callback: callback) else {
      return nil
    }
  }
  
  private var dirFD : Int32 = -1 {
    didSet {
      if oldValue != -1 {
        close(oldValue)
      }
    }
  }
  private var dispatchSource : DispatchSourceFileSystemObject?
  
  public func watch(path: String, callback: @escaping Callback) -> Bool {
    // Open the directory
    dirFD = open(path, O_EVTONLY)
    guard dirFD >= 0 else {
      return false
    }

    // Create and configure a DispatchSource to monitor it
    let dispatchSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: dirFD, eventMask: .write, queue: .main)
    dispatchSource.setEventHandler(handler: callback)
    dispatchSource.setCancelHandler {[weak self] in
      self?.dirFD = -1
    }
    self.dispatchSource = dispatchSource
    // Start monitoring
    dispatchSource.resume()
    // Success
    return true
  }
  
  public func stop() {
    // Leave if not monitoring
    guard let dispatchSource = dispatchSource else {
      return
    }
    // Don't listen to more events
    dispatchSource.setEventHandler(handler: nil)
    // Cancel the source (this will also close the directory)
    dispatchSource.cancel()
    self.dispatchSource = nil
  }
}
