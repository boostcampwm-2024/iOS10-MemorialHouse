import Combine

final class EditBookViewModel: ViewModelType {
    // MARK: - Type
    enum Input {
        case viewDidLoad
    }
    enum Output {
        case setTableView
    }
    
    // MARK: - Property
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var pages = [String]()
    
    // MARK: - Method
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                self?.fetchPages()
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    private func fetchPages() {
        pages = ["Image", "Video", "Text", "Audio"]
    }
}
