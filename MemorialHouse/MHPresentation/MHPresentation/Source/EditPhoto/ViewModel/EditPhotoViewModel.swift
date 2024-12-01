import MHFoundation
import MHDomain
import Combine

final class EditPhotoViewModel: ViewModelType {
    enum Input {
        case doneEditPhoto(imageData: Data, caption:String?)
    }
    
    enum Output {
        case moveToNextView
    }
    
    private let createMediaUseCase: CreateMediaUseCase
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let creationDate: Date
    
    init(
        createMediaUseCase: CreateMediaUseCase,
        creationDate: Date
    ) {
        self.createMediaUseCase = createMediaUseCase
        self.creationDate = creationDate
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .doneEditPhoto(let imageData, let caption):
                Task { await self?.createPhotoData(imageData: imageData, caption: caption) }
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func createPhotoData(imageData: Data, caption: String?) async {
        let media = MediaDescription(type: .image, attributes: [Constant.photoCaption: caption, Constant.photoCreationDate: creationDate])
        try? await createMediaUseCase.execute(media: media, data: imageData, at: media.id)
        output.send(.moveToNextView)
    }
}
