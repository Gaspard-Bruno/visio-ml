import SwiftUI
import UIKit
import MobileCoreServices

struct DocumentPicker: UIViewControllerRepresentable {

  class Coordinator: NSObject {

    var parent: DocumentPicker
    var pickerController: UIDocumentPickerViewController
    var presented = false

    init(_ parent: DocumentPicker) {
      self.parent = parent
      self.pickerController = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String],
      in: .open)
      super.init()
      pickerController.delegate = self
    }
  }

  @Binding var isPresented: Bool
  var onCancel = { }
  var onDocumentsPicked = { (_: [URL]) -> () in }

  func makeUIViewController(context: Context) -> UIViewController {
    UIViewController()
  }

  func updateUIViewController(_ presentingController: UIViewController, context: Context) {
    let pickerController = context.coordinator.pickerController
    if isPresented && !context.coordinator.presented {
      context.coordinator.presented.toggle()
      presentingController.present(pickerController, animated: true)
    } else if !isPresented && context.coordinator.presented {
      context.coordinator.presented.toggle()
      pickerController.dismiss(animated: true)
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}

extension DocumentPicker.Coordinator: UIDocumentPickerDelegate {
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    parent.isPresented.toggle()
    parent.onDocumentsPicked(urls)
  }
  
  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    parent.isPresented.toggle()
    parent.onCancel()
  }
}
