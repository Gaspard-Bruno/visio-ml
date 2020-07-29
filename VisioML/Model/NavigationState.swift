struct NavigationState {

  enum Navigator {
    case inputFolder
    case outputFolder
  }

  var currentModal: String?
  var navigator: Navigator = .inputFolder
  var isNavigatorVisible = true
  var showLabels = true

  mutating func toggleNavigator() {
    isNavigatorVisible.toggle()
  }

}
