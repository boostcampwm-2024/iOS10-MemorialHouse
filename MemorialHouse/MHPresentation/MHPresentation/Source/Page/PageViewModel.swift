import Foundation
import Combine

final class PageViewModel: ViewModelType {
    enum Input {
        
    }
    
    enum Output {
        
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    let index: Int
    
    init(index: Int) {
        self.index = index
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
