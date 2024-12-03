import Foundation
import Combine
import MHCore

final class CreateAudioViewModel: ViewModelType {
    // MARK: - Type
    enum Input {
        case audioSessionOpened(url: URL?)
        case audioButtonTapped
        case saveButtonTapped
        case viewDidDisappear
    }
    enum Output {
        case updatedAudioFileURL
        case audioStart
        case audioStop
        case savedAudioFile
        case deleteTemporaryAudioFile
    }
    
    // MARK: - Property
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var audioIsRecoding: Bool = false
    private let completion: (URL?) -> Void
    
    // MARK: - Initializer
    
    
    // MARK: - Method
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .audioSessionOpened(let url):
                self?.updateURL(url: url)
            case .audioButtonTapped:
                self?.audioButtonTapped()
            case .saveButtonTapped:
                self?.saveAudioFile()
            case .viewDidDisappear:
                self?.deleteAudioTemporaryFile()
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    // MARK: - Helper
    private func updateURL(url: URL?) {
        self.audioTemporaryFileURL = url
        output.send(.updatedAudioFileURL)
    }
    
    private func audioButtonTapped() {
        MHLogger.debug("audio button tapped in view model")
        switch audioIsRecoding {
        case false:
            output.send(.audioStart)
        case true:
            output.send(.audioStop)
        }
        audioIsRecoding.toggle()
    }
    
    private func saveAudioFile() {
        // TODO: - save audio file in the file system
        output.send(.savedAudioFile)
    }
    
    private func deleteAudioTemporaryFile() {
        guard let audioTemporaryFileURL else { return }
        try? FileManager.default.removeItem(at: audioTemporaryFileURL)
        output.send(.deleteTemporaryAudioFile)
    }
}
