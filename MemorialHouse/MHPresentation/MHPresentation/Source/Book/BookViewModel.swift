import MHFoundation
import MHDomain
import Combine

public final class BookViewModel: ViewModelType {
    enum Input {
        case viewDidLoad
        case loadPreviousPage
        case loadNextPage
    }
    
    enum Output {
        case fetchBook(bookTitle: String?)
        case loadFirstPage(page: Page?)
    }
    
    private let identifier: UUID
    private let fetchBookUseCase: FetchBookUseCase
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private var book: Book?
    private var nowPageIndex: Int = 0
    var previousPage: Page? { nowPageIndex > 0 ? book?.pages[nowPageIndex - 1] : nil }
    var nextPage: Page? { nowPageIndex < (book?.pages.count ?? 0) - 1 ? book?.pages[nowPageIndex + 1] : nil }
    
    init(
        identifier: UUID,
        fetchBookUseCase: FetchBookUseCase
    ) {
        self.identifier = identifier
        self.fetchBookUseCase = fetchBookUseCase
    }
    
    @MainActor
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                Task { try await self?.fetchBook() }
            case .loadPreviousPage:
                if self?.nowPageIndex ?? 0 > 0 {
                    self?.nowPageIndex -= 1
                }
            case .loadNextPage:
                if self?.nowPageIndex ?? 0 < (self?.book?.pages.count ?? 0) - 1 {
                    self?.nowPageIndex += 1
                }
            }
        }
        .store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }
    
    private func fetchBook() async throws {
        book = try await fetchBookUseCase.execute(id: identifier)
        output.send(.fetchBook(bookTitle: book?.title))
        output.send(.loadFirstPage(page: book?.pages[nowPageIndex]))
    }
}
