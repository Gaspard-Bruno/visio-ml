import Combine

class DataStore: ObservableObject {

  @Published var labels: [LabelModel] = AnnotatedImageModel.specimen.annotation
  @Published var selected: Int?
}
