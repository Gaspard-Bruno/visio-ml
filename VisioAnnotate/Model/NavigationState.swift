//
//  NavigationState.swift
//  VisioAnnotate
//
//  Created by dl on 2020-07-01.
//  Copyright © 2020 Gaspard+Bruno. All rights reserved.
//

struct NavigationState {

  var isNavigatorVisible = true

  mutating func toggleNavigator() {
    isNavigatorVisible.toggle()
  }
}
