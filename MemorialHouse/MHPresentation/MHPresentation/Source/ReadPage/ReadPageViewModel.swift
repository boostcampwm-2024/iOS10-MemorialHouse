import MHFoundation
import MHDomain
import Combine

public final class ReadPageViewModel: ViewModelType {
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case loadPage(text: String)
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let page: Page
    
    init(page: Page) {
        self.page = page
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                self?.loadPage()
            }
        }
        .store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }
    
    private func loadPage() {
        output.send(.loadPage(text: page.text))
    }
}
