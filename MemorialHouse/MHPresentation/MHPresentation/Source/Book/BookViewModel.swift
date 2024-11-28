import MHFoundation
import MHDomain
import Combine

public final class BookViewModel: ViewModelType {
    enum Input {
        
    }
    
    enum Output {
        
    }
    
    private let fetchBookUseCase: FetchBookUseCase
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private(set) var pageList = ["one", "two", "three"]
    
    init(fetchBookUseCase: FetchBookUseCase) {
        self.fetchBookUseCase = fetchBookUseCase
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { event in
            switch event {
                
            }
        }
        .store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }
}
