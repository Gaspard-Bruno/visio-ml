import Foundation

extension UUID {
  static func tiny() -> String {
    Self.init().uuidString.prefix(5).lowercased()
  }
}
