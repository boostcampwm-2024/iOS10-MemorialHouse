import Combine
import MHCore

final class CategoryViewModel: ViewModelType {
    enum Input {
        case addCategory(text: String)
        case updateCategory(index: Int, text: String)
        case deleteCategory(index: Int)
    }
    
    enum Output {
        case addedCategory
        case updatedCategory
        case deletedCategory
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private(set) var categories: [String]
    private(set) var currentCategoryIndex: Int
    
    init(cancellables: Set<AnyCancellable> = Set<AnyCancellable>(), categories: [String], currentCategoryIndex: Int) {
        self.cancellables = cancellables
        self.categories = categories
        self.currentCategoryIndex = currentCategoryIndex
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .addCategory(let text):
                self?.addCategory(text: text)
            case .updateCategory(let index, let text):
                self?.updateCategory(index: index, text: text)
            case .deleteCategory(let index):
                self?.deleteCategory(index: index)
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func addCategory(text: String) {
        categories.append(text)
        output.send(.addedCategory)
    }
    
    private func updateCategory(index: Int, text: String) {
        guard index >= 0 && index < categories.count else {
            MHLogger.error("유효하지 않은 인덱스: \(index)")
            return
        }
        categories[index] = text
        output.send(.updatedCategory)
    }
    
    private func deleteCategory(index: Int) {
        guard index >= 0 && index < categories.count else {
            MHLogger.error("유효하지 않은 인덱스: \(index)")
            return
        }
        categories.remove(at: index)
        output.send(.deletedCategory)
    }
}
