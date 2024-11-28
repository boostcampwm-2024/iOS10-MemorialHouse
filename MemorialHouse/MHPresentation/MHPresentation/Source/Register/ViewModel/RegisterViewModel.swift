import MHFoundation
import Combine

public final class RegisterViewModel: ViewModelType {
    enum Input {
        case registerTextFieldEdited(text: String?)
        case registerButtonTapped(text: String)
    }
    
    enum Output {
        case registerButtonEnabled(isEnabled: Bool)
        case moveToHome
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    public init() { }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .registerTextFieldEdited(let text):
                self?.validateTextField(text: text)
            case .registerButtonTapped(let text):
                self?.registerButtonTapped(text: text)
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func validateTextField(text: String?) {
        guard let text else {
            output.send(.registerButtonEnabled(isEnabled: false))
            return
        }
        output.send(.registerButtonEnabled(isEnabled: !text.isEmpty && text.count < 11))
    }
    
    private func registerButtonTapped(text: String) {
        UserDefaults.standard.set(
            text,
            forKey: Constant.houseNameUserDefaultKey
        )
        output.send(.moveToHome)
    }
}
