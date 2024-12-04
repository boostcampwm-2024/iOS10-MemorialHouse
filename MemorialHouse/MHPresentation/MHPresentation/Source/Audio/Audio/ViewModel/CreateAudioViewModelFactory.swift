import MHFoundation
import MHDomain

public struct CreateAudioViewModelFactory {
    private let temporaryStoreMediaUseCase: TemporaryStoreMediaUseCase
    
    public init(temporaryStoreMediaUseCase: TemporaryStoreMediaUseCase) {
        self.temporaryStoreMediaUseCase = temporaryStoreMediaUseCase
    }
    
    public func make(completion: @escaping (MediaDescription?) -> Void) -> CreateAudioViewModel {
        CreateAudioViewModel(
            temporaryStoreMediaUsecase: temporaryStoreMediaUseCase,
            completion: completion
            )
    }
}
