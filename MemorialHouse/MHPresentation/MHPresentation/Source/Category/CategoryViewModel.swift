import Combine
import MHFoundation

final class CategoryViewModel: ViewModelType {
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case fetchedCategories
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private(set) var categories: [String]
    private(set) var currentCategoryIndex: Int
    
    init(categories: [String], currentCategoryIndex: Int) {
        self.categories = categories
        self.currentCategoryIndex = currentCategoryIndex
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                self?.fetchCategories()
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func fetchCategories() {
        // TODO: 데이터 받아오기
        output.send(.fetchedCategories)
    }
}
