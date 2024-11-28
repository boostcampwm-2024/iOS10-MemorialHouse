import MHFoundation
import MHDomain
import Combine

public final class ReadPageViewModel: ViewModelType {
    enum Input {
        
    }
    
    enum Output {
        
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let page: Page
    
    init(page: Page) {
        self.page = page
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
