import MHFoundation
import MHDomain
import Combine

public final class RegisterViewModel: ViewModelType {
    enum Input {
        case registerTextFieldEdited(text: String?)
        case registerButtonTapped(text: String)
    }
    
    enum Output {
        case registerButtonEnabled(isEnabled: Bool)
        case moveToHome
        case createFailure(errorMessage: String)
    }
    
    private let createMemorialHouseNameUseCase: CreateMemorialHouseNameUseCase
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        createMemorialHouseNameUseCase: CreateMemorialHouseNameUseCase
    ) {
        self.createMemorialHouseNameUseCase = createMemorialHouseNameUseCase
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .registerTextFieldEdited(let text):
                self?.validateTextField(text: text)
            case .registerButtonTapped(let memorialHouseName):
                Task {
                    do {
                        try await self?.registerButtonTapped(with: memorialHouseName)
                        self?.output.send(.moveToHome)
                    } catch {
                        self?.output.send(.createFailure(errorMessage: error.localizedDescription))
                    }
                }
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
    
    private func registerButtonTapped(with memorialHouseName: String) async throws {
        try await createMemorialHouseNameUseCase.execute(with: memorialHouseName)
    }
}
