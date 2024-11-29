import Combine
import MHDomain
import MHCore

final class BookCategoryViewModel: ViewModelType {
    enum Input {
        case viewDidLoad
        case addCategory(text: String)
        case updateCategory(index: Int, text: String)
        case deleteCategory(index: Int)
    }
    
    enum Output {
        case createdCategory
        case fetchCategories
        case updatedCategory
        case deletedCategory
        case failed(String)
    }
    
    private let createBookCategoryUseCase: CreateBookCategoryUseCase
    private let fetchBookCategoriesUseCase: FetchBookCategoriesUseCase
    private let updateBookCategoryUseCase: UpdateBookCategoryUseCase
    private let deleteBookCategoryUseCase: DeleteBookCategoryUseCase
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private(set) var categories = [
        BookCategory(order: 0, name: "전체"),
        BookCategory(order: 1, name: "즐겨찾기")
    ]
    private(set) var currentCategoryName = ""
    
    init(
        createBookCategoryUseCase: CreateBookCategoryUseCase,
        fetchBookCategoriesUseCase: FetchBookCategoriesUseCase,
        updateBookCategoryUseCase: UpdateBookCategoryUseCase,
        deleteBookCategoryUseCase: DeleteBookCategoryUseCase
    ) {
        self.createBookCategoryUseCase = createBookCategoryUseCase
        self.fetchBookCategoriesUseCase = fetchBookCategoriesUseCase
        self.updateBookCategoryUseCase = updateBookCategoryUseCase
        self.deleteBookCategoryUseCase = deleteBookCategoryUseCase
    }
    
    func setup(currentCategory: String) {
        self.currentCategoryName = currentCategory
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            Task {
                switch event {
                case .viewDidLoad:
                    await self?.fetchCategories()
                case .addCategory(let text):
                    await self?.createCategory(text: text)
                case .updateCategory(let index, let text):
                    await self?.updateCategory(index: index, text: text)
                case .deleteCategory(let index):
                    await self?.deleteCategory(index: index)
                }
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    // FIXME: MainActor 제거
    @MainActor
    private func createCategory(text: String) async {
        do {
            let category = BookCategory(order: categories.count, name: text)
            try await createBookCategoryUseCase.execute(with: category)
            categories.append(category)
            output.send(.createdCategory)
        } catch {
            MHLogger.error("카테고리를 생성하는데 실패했습니다: \(error)")
            output.send(.failed("카테고리를 생성하는데 실패했습니다"))
        }
    }
    
    @MainActor
    private func fetchCategories() async {
        do {
            let fetchedCategories = try await fetchBookCategoriesUseCase.execute()
            categories.append(contentsOf: fetchedCategories)
            output.send(.fetchCategories)
        } catch {
            MHLogger.error("카테고리를 불러오는데 실패했습니다: \(error)")
            output.send(.failed("카테고리를 불러오는데 실패했습니다"))
        }
    }
    
    @MainActor
    private func updateCategory(index: Int, text: String) async {
        guard index >= 0 && index < categories.count else {
            MHLogger.error("유효하지 않은 인덱스: \(index)")
            output.send(.failed("유효하지 않은 인덱스: \(index)"))
            return
        }
        
        do {
            let oldName = categories[index].name
            let category = BookCategory(order: index, name: text)
            try await updateBookCategoryUseCase.execute(oldName: oldName, with: category)
            categories[index] = category
            output.send(.updatedCategory)
        } catch {
            MHLogger.error("카테고리를 업데이트하는데 실패했습니다: \(error)")
            output.send(.failed("카테고리를 업데이트하는데 실패했습니다"))
        }
    }
    
    @MainActor
    private func deleteCategory(index: Int) async {
        guard index >= 0 && index < categories.count else {
            MHLogger.error("유효하지 않은 인덱스: \(index)")
            output.send(.failed("유효하지 않은 인덱스: \(index)"))
            return
        }
        
        do {
            let categoryName = categories[index].name
            try await deleteBookCategoryUseCase.execute(with: categoryName)
            categories.remove(at: index)
            output.send(.deletedCategory)
        } catch {
            MHLogger.error("카테고리를 삭제하는데 실패했습니다: \(error)")
            output.send(.failed("카테고리를 삭제하는데 실패했습니다"))
        }
    }
}