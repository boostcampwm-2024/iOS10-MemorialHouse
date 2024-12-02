import MHFoundation
import MHDomain
import Combine

final class ModifyBookCoverViewModel: ViewModelType {
    enum Input {
        
    }
    
    enum Output {
        
    }
    
    private let bookID: UUID
    private let fetchBookCoverUseCase: FetchBookCoverUseCase
    private let updateBookCoverUseCase: UpdateBookCoverUseCase
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        fetchBookCoverUseCase: FetchBookCoverUseCase,
        updateBookCoverUseCase: UpdateBookCoverUseCase,
        bookID: UUID
    ) {
        self.bookID = bookID
        self.fetchBookCoverUseCase = fetchBookCoverUseCase
        self.updateBookCoverUseCase = updateBookCoverUseCase
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { event in
            switch event {
                
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
}
