import MHFoundation
import MHDomain
import Combine

public final class RegisterViewModel: ViewModelType {
    public enum Input {
        case registerTextFieldEdited(text: String?)
        case registerButtonTapped(memorialHouseName: String)
    }
    
    public enum Output: Equatable {
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
                Task { await self?.registerButtonTapped(with: memorialHouseName) }
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
    
    @MainActor
    private func registerButtonTapped(with memorialHouseName: String) async {
        do {
            try await createMemorialHouseNameUseCase.execute(with: memorialHouseName)
            self.output.send(.moveToHome)
        } catch {
            self.output.send(.createFailure(errorMessage: error.localizedDescription))
        }
    }
}
