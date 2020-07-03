
import SwiftUI

struct ImageSizePrefKey: PreferenceKey {
  static var defaultValue: CGSize? = nil
  static func reduce(value: inout CGSize? , nextValue: () -> CGSize?) {
    guard let nextVal = nextValue() else {
      return
    }
    value = nextVal
  }
}
