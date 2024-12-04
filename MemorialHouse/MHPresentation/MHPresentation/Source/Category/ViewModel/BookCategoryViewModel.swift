import Combine
import MHDomain
import MHCore

final class BookCategoryViewModel: ViewModelType {
    enum Input {
        case createCategory(text: String)
        case fetchCategories
        case updateCategory(index: Int, text: String)
        case deleteCategory(index: Int)
    }
    
    enum Output {
        case createdCategory
        case fetchCategories
        case updatedCategory
        case deletedCategory
        case failure(String)
    }
    
    private let createBookCategoryUseCase: CreateBookCategoryUseCase
    private let fetchBookCategoriesUseCase: FetchBookCategoriesUseCase
    private let updateBookCategoryUseCase: UpdateBookCategoryUseCase
    private let deleteBookCategoryUseCase: DeleteBookCategoryUseCase
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private(set) var categories = [BookCategory]()
    private(set) var currentCategoryName = ""
    
    init(
        createBookCategoryUseCase: CreateBookCategoryUseCase,
        fetchBookCategoriesUseCase: FetchBookCategoriesUseCase,
        updateBookCategoryUseCase: UpdateBookCategoryUseCase,
        deleteBookCategoryUseCase: DeleteBookCategoryUseCase,
        categories: [BookCategory] = [
            BookCategory(order: 0, name: "전체"),
            BookCategory(order: 1, name: "즐겨찾기")
        ]
    ) {
        self.createBookCategoryUseCase = createBookCategoryUseCase
        self.fetchBookCategoriesUseCase = fetchBookCategoriesUseCase
        self.updateBookCategoryUseCase = updateBookCategoryUseCase
        self.deleteBookCategoryUseCase = deleteBookCategoryUseCase
        self.categories = categories
    }
    
    func setup(currentCategory: String) {
        self.currentCategoryName = currentCategory
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            Task {
                switch event {
                case .createCategory(let name):
                    await self?.createCategory(name: name)
                case .fetchCategories:
                    await self?.fetchCategories()
                case .updateCategory(let index, let text):
                    await self?.updateCategory(index: index, name: text)
                case .deleteCategory(let index):
                    await self?.deleteCategory(index: index)
                }
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func createCategory(name: String) async {
        guard validateCategoryName(with: name) else {
            MHLogger.error("카테고리 생성 유효성 검증 실패: \(name)" + #function)
            output.send(.failure("카테고리 생성 유효성 검증 실패"))
            return
        }
        
        do {
            let category = BookCategory(order: categories.count, name: name)
            try await createBookCategoryUseCase.execute(with: category)
            categories.append(category)
            output.send(.createdCategory)
        } catch {
            MHLogger.error("카테고리를 생성하는데 실패했습니다: \(error)" + #function)
            output.send(.failure("카테고리를 생성하는데 실패했습니다"))
        }
    }
    
    private func fetchCategories() async {
        do {
            let fetchedCategories = try await fetchBookCategoriesUseCase.execute()
            categories.append(contentsOf: fetchedCategories)
            output.send(.fetchCategories)
        } catch {
            MHLogger.error("카테고리를 불러오는데 실패했습니다: \(error)" + #function)
            output.send(.failure("카테고리를 불러오는데 실패했습니다"))
        }
    }
    
    private func updateCategory(index: Int, name: String) async {
        guard validateIndex(index),
              validateCategoryName(with: name) else {
            MHLogger.error("카테고리 업데이트 유효성 검증 실패: \(name)" + #function)
            output.send(.failure("카테고리 업데이트 유효성 검증 실패"))
            return
        }
        
        do {
            let oldName = categories[index].name
            let category = BookCategory(order: index, name: name)
            try await updateBookCategoryUseCase.execute(oldName: oldName, with: category)
            categories[index] = category
            output.send(.updatedCategory)
        } catch {
            MHLogger.error("카테고리를 업데이트하는데 실패했습니다: \(error)" + #function)
            output.send(.failure("카테고리를 업데이트하는데 실패했습니다"))
        }
    }
    
    private func deleteCategory(index: Int) async {
        guard validateIndex(index) else {
            MHLogger.error("카테고리 삭제 유효성 검증 실패: \(index)" + #function)
            output.send(.failure("카테고리를 삭제하는데 실패했습니다"))
            return
        }
        
        do {
            let categoryName = categories[index].name
            try await deleteBookCategoryUseCase.execute(with: categoryName)
            categories.remove(at: index)
            output.send(.deletedCategory)
        } catch {
            MHLogger.error("카테고리를 삭제하는데 실패했습니다: \(error)" + #function)
            output.send(.failure("카테고리를 삭제하는데 실패했습니다"))
        }
    }
    
    // MARK: - 카테고리 유효성 검사
    private func validateCategoryName(with name: String) -> Bool {
        return validateNonEmptyName(name)
            && validateUniqueName(name)
            && validateNameLength(name)
    }
    
    // 인덱스 유효성 검사
    private func validateIndex(_ index: Int) -> Bool {
        guard index >= 0 && index < categories.count else {
            MHLogger.error("유효하지 않은 인덱스: \(index)" + #function)
            output.send(.failure("유효하지 않은 인덱스: \(index)"))
            return false
        }
        return true
    }

    // 공백 또는 빈 문자열 검사
    private func validateNonEmptyName(_ name: String) -> Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            MHLogger.error("카테고리 이름이 비어있거나 공백만 포함되어 있음: \(name)" + #function)
            output.send(.failure("카테고리 이름은 공백일 수 없습니다."))
            return false
        }
        return true
    }

    // 중복 이름 검사
    private func validateUniqueName(_ name: String) -> Bool {
        guard !categories.contains(where: { $0.name == name }) else {
            MHLogger.error("중복된 카테고리 이름: \(name)" + #function)
            output.send(.failure("이미 존재하는 카테고리: \(name)"))
            return false
        }
        return true
    }

    // 이름 길이 검사
    private func validateNameLength(_ name: String) -> Bool {
        guard name.count <= 10 else {
            MHLogger.error("카테고리 이름이 너무 깁니다: \(name)" + #function)
            output.send(.failure("카테고리 이름은 10자 이하여야 합니다."))
            return false
        }
        return true
    }
}
