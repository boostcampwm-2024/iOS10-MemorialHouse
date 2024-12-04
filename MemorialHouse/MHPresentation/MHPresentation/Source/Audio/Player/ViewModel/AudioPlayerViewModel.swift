import MHFoundation
import Combine

final public class AudioPlayerViewModel: ViewModelType {
    enum Input {
        case audioStateButtonTapped
    }
    enum Output {
        case getAudioState(AudioPlayState)
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var audioPlayState: AudioPlayState = .pause
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .audioStateButtonTapped:
                self?.audioStateChanged()
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func audioStateChanged() {
        switch audioPlayState {
        case .pause:
            audioPlayState = .play
            output.send(.getAudioState(.play))
        case .play:
            audioPlayState = .pause
            output.send(.getAudioState(.pause))
        }
        return
    }
}
