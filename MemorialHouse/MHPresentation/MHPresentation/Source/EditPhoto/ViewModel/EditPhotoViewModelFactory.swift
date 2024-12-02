import MHFoundation
import MHDomain

public struct EditPhotoViewModelFactory {
    private let createMediaUseCase: CreateMediaUseCase
    
    public init(createMediaUseCase: CreateMediaUseCase) {
        self.createMediaUseCase = createMediaUseCase
    }
    
    func make(creationDate: Date) -> EditPhotoViewModel {
        return EditPhotoViewModel(
            createMediaUseCase: createMediaUseCase,
            creationDate: creationDate
        )
    }
}
