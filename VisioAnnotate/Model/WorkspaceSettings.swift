import Foundation

struct WorkspaceSettings {

  var markedOnly = false
  var backgrounds: URL?
  var times = 1
  
}

extension WorkspaceSettings: Codable { }
