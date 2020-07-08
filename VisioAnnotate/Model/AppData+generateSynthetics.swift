import Foundation

extension AppData {
  func generateSynthetics(selectionOnly: Bool) {
  
    folderWatcher?.suspend()

    let initialSet = selectionOnly
      ? annotatedImages.filter { $0.isMarked }
      : annotatedImages

    let tasks = initialSet.flatMap {
      [
        SyntheticsTask(annotatedImage: $0, operations: [.rotate]),
        SyntheticsTask(annotatedImage: $0, operations: [.scale, .rotate]),
        SyntheticsTask(annotatedImage: $0, operations: [.rotate, .scale]),
        SyntheticsTask(annotatedImage: $0, operations: [.scale]),
        SyntheticsTask(annotatedImage: $0, operations: [.emboss]),
        SyntheticsTask(annotatedImage: $0, operations: [.scale, .emboss]),
        SyntheticsTask(annotatedImage: $0, operations: [.emboss, .scale]),
        SyntheticsTask(annotatedImage: $0, operations: [.flip, .noise]),
        SyntheticsTask(annotatedImage: $0, operations: [.blur]),
        SyntheticsTask(annotatedImage: $0, operations: [.monochrome]),
        SyntheticsTask(annotatedImage: $0, operations: [.blur, .monochrome]),
        SyntheticsTask(annotatedImage: $0, operations: [.monochrome, .blur]),
        SyntheticsTask(annotatedImage: $0, operations: [.flip, .blur]),
        SyntheticsTask(annotatedImage: $0, operations: [.flip, .monochrome]),
        SyntheticsTask(annotatedImage: $0, operations: [.flip, .blur, .monochrome]),
        SyntheticsTask(annotatedImage: $0, operations: [.flip, .monochrome, .blur])
      ]
    }
    tasks.forEach {
      self.annotatedImages.append(AnnotatedImage(
        url: $0.resultUrl, annotations: [], isEnabled: false
      ))
    }
    
    tasks.processAll { task in
      DispatchQueue.main.async {
        self.syntheticTaskComplete(task)
      }
    }
  }
  
  func syntheticTaskComplete(_ task: SyntheticsTask) {
    guard let i = annotatedImages.firstIndex(where: { $0.url == task.resultUrl }) else {
      return
    }
    annotatedImages[i].annotations = task.resultAnnotations
    annotatedImages[i].isEnabled.toggle()
    if pendingImages == 0 {
      folderWatcher?.resume()
    }
  }
}
