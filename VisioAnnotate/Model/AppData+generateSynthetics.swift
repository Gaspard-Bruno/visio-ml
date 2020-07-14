import Foundation

extension AppData {

  func makeTask(_ image: AnnotatedImage, _ ops: [Operation]) -> SyntheticsTask {
    SyntheticsTask(annotatedImage: image, settings: settings, operations: ops)
  }

  func generateSynthetics() {
  
    folderWatcher?.suspend()

    let initialSet = settings.markedOnly
      ? annotatedImages.filter { $0.isMarked }
      : annotatedImages

    let tasks = initialSet.flatMap { img in
      Operation.validCombinations
      .excluding(operations: settings.excludeOperations)
      .flatMap { ops in
        (0 ..< settings.times).map { _ in
          makeTask(img, ops)
        }
      }
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
