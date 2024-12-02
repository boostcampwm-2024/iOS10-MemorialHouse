import MHFoundation
import MHDomain
import Combine

final class ModifyBookCoverViewModel: ViewModelType {
    enum Input {
        
    }
    
    enum Output {
        
    }
    
    private let bookID: UUID
    private let fetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase
    private let fetchBookCoverUseCase: FetchBookCoverUseCase
    private let updateBookCoverUseCase: UpdateBookCoverUseCase
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        fetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase,
        fetchBookCoverUseCase: FetchBookCoverUseCase,
        updateBookCoverUseCase: UpdateBookCoverUseCase,
        bookID: UUID
    ) {
        self.fetchMemorialHouseNameUseCase = fetchMemorialHouseNameUseCase
        self.fetchBookCoverUseCase = fetchBookCoverUseCase
        self.updateBookCoverUseCase = updateBookCoverUseCase
        self.bookID = bookID
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { event in
            switch event {
                
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
}
