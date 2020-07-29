// Synthetic operation (filter)
enum Operation: String, Hashable, Codable, CaseIterable, Identifiable {
  case flip
  case scale
  case rotate
  case background
  case blur
  case monochrome
  case emboss
  case noise
  case crop
  case cutout

  var id: some Hashable {
    rawValue
  }
}

extension Array where Element == [Operation] {
  func excluding(operations excludeOperations: [Operation]) -> [[Operation]] {
    filter { opSet in
      // combination does not contain an excluded filter
      !opSet.reduce(into: false) { result, op in
        result = result || excludeOperations.contains(op)
      }
    }
  }

  func including(operations includeOperations: [Operation]) -> [[Operation]] {
    includeOperations.count == 0
    ? self
    : filter { opSet in
      // combination does not contain an excluded filter
      opSet.reduce(into: false) { result, op in
        result = result || includeOperations.contains(op)
      }
    }
  }

}
