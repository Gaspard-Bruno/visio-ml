struct NavigationState {

  var currentModal: String?
  var isNavigatorVisible = true

  mutating func toggleNavigator() {
    isNavigatorVisible.toggle()
  }
  

}
