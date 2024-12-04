import Foundation
import Combine
import MHCore
import MHDomain

public final class CreateAudioViewModel: ViewModelType {
    // MARK: - Type
    enum Input {
        case prepareTemporaryAudio
        case audioButtonTapped
        case saveButtonTapped
        case recordCancelled
    }
    enum Output {
        case audioFileURL(url: URL)
        case audioStart
        case audioStop
        case recordCompleted
    }
    
    // MARK: - Property
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var audioIsRecoding: Bool = false
    private let completion: (MediaDescription?) -> Void
    private let temporaryStoreMediaUsecase: TemporaryStoreMediaUseCase
    private var mediaDescription: MediaDescription?
    
    // MARK: - Initializer
    init(
        temporaryStoreMediaUsecase: TemporaryStoreMediaUseCase,
        completion: @escaping (MediaDescription?) -> Void
    ) {
        self.temporaryStoreMediaUsecase = temporaryStoreMediaUsecase
        self.completion = completion
    }
    
    // MARK: - Method
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .prepareTemporaryAudio:
                Task { await self?.prepareTemporaryAudio() }
            case .audioButtonTapped:
                self?.audioButtonTapped()
            case .saveButtonTapped:
                self?.completeRecord(withCompletion: true)
            case .recordCancelled:
                self?.completeRecord(withCompletion: false)
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    // MARK: - Helper
    private func prepareTemporaryAudio() async {
        let mediaDescription = MediaDescription(type: .audio)
        self.mediaDescription = mediaDescription
        do {
            let url = try await temporaryStoreMediaUsecase.execute(media: mediaDescription)
            output.send(.audioFileURL(url: url))
        } catch {
            MHLogger.error("Error in store audio file url: \(error.localizedDescription)")
            completion(nil)
            output.send(.recordCompleted)
        }
    }
    private func audioButtonTapped() {
        switch audioIsRecoding {
        case false:
            output.send(.audioStart)
        case true:
            output.send(.audioStop)
        }
        audioIsRecoding.toggle()
    }
    
    private func completeRecord(withCompletion: Bool) {
        if audioIsRecoding {
            output.send(.audioStop)
        }
        output.send(.recordCompleted)
        
        if withCompletion {
            completion(mediaDescription)
        }
    }
}
