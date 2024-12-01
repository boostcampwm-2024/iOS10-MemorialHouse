import Foundation
import Combine
import MHCore

public final class CreateAudioViewModel: ViewModelType {
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
    
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var identifier: UUID?
    private var audioTemporaryFileURL: URL?
    private var audioIsRecoding: Bool = false
    
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
