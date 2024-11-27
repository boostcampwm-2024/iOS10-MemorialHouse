import Combine
import MHDomain
import MHCore

final class CategoryViewModel: ViewModelType {
    enum Input {
        case addCategory(text: String)
        case updateCategory(index: Int, text: String)
        case deleteCategory(index: Int)
    }
    
    enum Output {
        case createdCategory
        case updatedCategory
        case deletedCategory
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private let createCategoryUseCase: CreateCategoryUseCase
    private let updateCategoryUseCase: UpdateCategoryUseCase
    private let deleteCategoryUseCase: DeleteCategoryUseCase
    private var cancellables = Set<AnyCancellable>()
    private(set) var categories = [String]()
    private(set) var currentCategory = ""
    
    init(
        createCategoryUseCase: CreateCategoryUseCase,
        updateCategoryUseCase: UpdateCategoryUseCase,
        deleteCategoryUseCase: DeleteCategoryUseCase
    ) {
        self.createCategoryUseCase = createCategoryUseCase
        self.updateCategoryUseCase = updateCategoryUseCase
        self.deleteCategoryUseCase = deleteCategoryUseCase
    }
    
    func setup(currentCategory: String) {
        self.currentCategory = currentCategory
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
        output.send(.createdCategory)
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
