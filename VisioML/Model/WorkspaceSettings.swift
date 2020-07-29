import Foundation

struct WorkspaceSettings {

  var markedOnly = false
  var backgrounds: URL?
  var times = 1
  var excludeOperations: [Operation] = []
  var includeOperations: [Operation] = []
  
}

extension WorkspaceSettings: Codable { }
