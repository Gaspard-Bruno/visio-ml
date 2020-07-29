import Foundation

extension AppData {

  func makeTask(_ image: AnnotatedImage, _ ops: [Operation]) -> SyntheticsTask {
    SyntheticsTask(annotatedImage: image, folder: outFolder, settings: settings, operations: ops)
  }

  func cancelSynthetics() {
    cancelSyntheticsProcess.toggle()
    if self.outFolder == nil {
      self.annotatedImages.removeAll { !$0.isEnabled }
    } else {
      self.outputImages.removeAll { !$0.isEnabled }
    }
  }
  
  func generateSynthetics() {
  
    folderWatcher?.suspend()

    let initialSet = settings.markedOnly
      ? annotatedImages.filter { $0.isMarked }
      : annotatedImages

    let tasks = initialSet.flatMap { img in
      Operation.validCombinations
      .excluding(operations: settings.excludeOperations)
      .including(operations: settings.includeOperations)
      .flatMap { ops in
        (0 ..< settings.times).map { _ in
          makeTask(img, ops)
        }
      }
    }
    tasks.forEach {
      let a = AnnotatedImage(
        url: $0.resultUrl, annotations: [], isEnabled: false
      )
      if self.outFolder == nil {
        self.annotatedImages.append(a)
      } else {
        self.outputImages.append(a)
      }
      
    }
    tasks.processAll { task in
      DispatchQueue.main.async {
        self.syntheticTaskComplete(task)
      }
    }
  }
  
  func syntheticTaskComplete(_ task: SyntheticsTask) {
    if outFolder == nil {
      guard let i = annotatedImages.firstIndex(where: { $0.url == task.resultUrl }) else {
        return
      }
      annotatedImages[i].annotations = task.resultAnnotations
      annotatedImages[i].isEnabled.toggle()
    } else {
      guard let i = outputImages.firstIndex(where: { $0.url == task.resultUrl }) else {
        return
      }
      outputImages[i].annotations = task.resultAnnotations
      outputImages[i].isEnabled.toggle()
    }
    if pendingImages == 0 {
      folderWatcher?.resume()
    }
  }
}
