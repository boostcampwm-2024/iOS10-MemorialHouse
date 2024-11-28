import Combine
import MHDomain
import MHCore

final class BookCategoryViewModel: ViewModelType {
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
    
    private let createBookCategoryUseCase: CreateBookCategoryUseCase
    private let updateBookCategoryUseCase: UpdateBookCategoryUseCase
    private let deleteBookCategoryUseCase: DeleteBookCategoryUseCase
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private(set) var categories = ["전체", "즐겨찾기"]
    private(set) var currentCategory = ""
    
    init(
        createBookCategoryUseCase: CreateBookCategoryUseCase,
        updateBookCategoryUseCase: UpdateBookCategoryUseCase,
        deleteBookCategoryUseCase: DeleteBookCategoryUseCase
    ) {
        self.createBookCategoryUseCase = createBookCategoryUseCase
        self.updateBookCategoryUseCase = updateBookCategoryUseCase
        self.deleteBookCategoryUseCase = deleteBookCategoryUseCase
    }
    
    func setup(currentCategory: String) {
        self.currentCategory = currentCategory
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            Task {
                switch event {
                case .addCategory(let text):
                    do {
                        try await self?.createCategory(text: text)
                    } catch {
                        
                    }
                case .updateCategory(let index, let text):
                    try await self?.updateCategory(index: index, text: text)
                case .deleteCategory(let index):
                    try await self?.deleteCategory(index: index)
                }
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func createCategory(text: String) async throws {
        try await createBookCategoryUseCase.execute(name: text)
        categories.append(text)
        output.send(.createdCategory)
    }
    
    private func updateCategory(index: Int, text: String) async throws {
        guard index >= 0 && index < categories.count else {
            MHLogger.error("유효하지 않은 인덱스: \(index)")
            return
        }
        categories[index] = text
        output.send(.updatedCategory)
    }
    
    private func deleteCategory(index: Int) async throws {
        guard index >= 0 && index < categories.count else {
            MHLogger.error("유효하지 않은 인덱스: \(index)")
            return
        }
        categories.remove(at: index)
        output.send(.deletedCategory)
    }
}
