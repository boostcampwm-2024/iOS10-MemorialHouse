import MHDomain

public struct RegisterViewModelFactory: Sendable {
    private let createMemorialHouseNameUseCase: CreateMemorialHouseNameUseCase
    
    public init(
        createMemorialHouseNameUseCase: CreateMemorialHouseNameUseCase
    ) {
        self.createMemorialHouseNameUseCase = createMemorialHouseNameUseCase
    }
    
    public func make() -> RegisterViewModel {
        return RegisterViewModel(
            createMemorialHouseNameUseCase: createMemorialHouseNameUseCase
        )
    }
}
