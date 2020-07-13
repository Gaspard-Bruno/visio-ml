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
//      .filter { ops in
//      }
      .map { ops in
        makeTask(img, ops)
      }
//      [
//        makeTask($0, [.crop])
//        makeTask($0, [.background]),
//        makeTask($0, [.background]),
//        makeTask($0, [.background]),
//        makeTask($0, [.scale, .rotate, .background]),
//        makeTask($0, [.scale, .rotate, .background]),
//        makeTask($0, [.scale, .rotate, .background]),
//        makeTask($0, [.background, .monochrome, .noise]),
//        makeTask($0, [.background, .monochrome, .noise]),
//        makeTask($0, [.background, .monochrome, .noise]),
//        makeTask($0, [.scale, .rotate, .monochrome, .background, .noise]),
//        makeTask($0, [.scale, .rotate, .monochrome, .background, .noise]),
//        makeTask($0, [.scale, .rotate, .monochrome, .background, .noise]),
//        makeTask($0, [.scale, .rotate, .monochrome, .background, .noise]),
//        makeTask($0, [.scale, .rotate, .monochrome, .background, .noise]),
//        makeTask($0, [.scale, .rotate, .monochrome, .background, .noise]),
//        makeTask($0, [.rotate]),
//        makeTask($0, [.scale, .rotate]),
//        makeTask($0, [.rotate, .scale]),
//        makeTask($0, [.scale]),
//        makeTask($0, [.emboss]),
//        makeTask($0, [.scale, .emboss]),
//        makeTask($0, [.emboss, .scale]),
//        makeTask($0, [.flip, .noise]),
//        makeTask($0, [.blur]),
//        makeTask($0, [.monochrome]),
//        makeTask($0, [.blur, .monochrome]),
//        makeTask($0, [.monochrome, .blur]),
//        makeTask($0, [.flip, .blur]),
//        makeTask($0, [.flip, .monochrome]),
//        makeTask($0, [.flip, .blur, .monochrome]),
//        makeTask($0, [.flip, .monochrome, .blur])
//      ]
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
