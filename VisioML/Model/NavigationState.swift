struct NavigationState {

  var currentModal: String?
  var isNavigatorVisible = true
  var showLabels = true

  mutating func toggleNavigator() {
    isNavigatorVisible.toggle()
  }
  

}
