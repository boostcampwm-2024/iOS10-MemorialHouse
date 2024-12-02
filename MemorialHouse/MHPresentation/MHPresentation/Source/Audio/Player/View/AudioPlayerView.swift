import UIKit
import Combine
import AVFAudio
import MHCore


final public class AudioPlayerView: UIView {
    
    // MARK: - Property
    // data bind
    private var viewModel: AudioPlayerViewModel?
    private let input = PassthroughSubject<AudioPlayerViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    // audio
    let audioPlayer: AVAudioPlayer?
    var audioPlayState: AudioPlayState
    
    // MARK: - ViewComponent
    let audioProgressView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .mhPink
        backgroundView.layer.cornerRadius = 5
        
        return backgroundView
    }()
    let audioStateButton: UIButton = {
        let button = UIButton()
        return button
    }()
    let playImage = UIImage(systemName: "play.fill")
    let pauseImage = UIImage(systemName: "pause.fill")
    let audioStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "audio_play")
        
        return imageView
    }()
    let audioPlayTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = UIFont.ownglyphBerry(size: 14)
        label.textAlignment = .left
        label.textColor = .black
        
        return label
    }()
    
    public override init(frame: CGRect) {
        audioPlayer = try? AVAudioPlayer(contentsOf: .documentsDirectory.appendingPathComponent("audio.m4a"))
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        audioPlayer = try? AVAudioPlayer(contentsOf: .documentsDirectory.appendingPathComponent("audio.m4a"))
        super.init(frame: .zero)
    }
    
    // MARK: - setup
    private func setup() {
        backgroundColor = .baseBackground
        layer.cornerRadius = 5
    }
    
    // MARK: - bind
    private func bind() {
        let output = viewModel?.transform(input: input.eraseToAnyPublisher())
        output?.sink(receiveValue: { [weak self] event in
            switch event {
            case .getAudioState(let state):
                self?.updateAudioPlayImage(audioPlayState: state)
            }
        }).store(in: &cancellables)
    }
    
    private func configureAddSubview() {
        addSubview(audioProgressView)
        addSubview(audioStateButton)
        addSubview(audioPlayTimeLabel)
    }
    
    private func configureContstraints() {
        audioProgressView.setAnchor(
            top: topAnchor,
            leading: leadingAnchor,
            bottom: bottomAnchor,
            width: 10
        )
        
        audioStateButton.setAnchor(
            top: topAnchor,
            leading: leadingAnchor,
            bottom: bottomAnchor,
            width: frame.height
        )
        
        audioPlayTimeLabel.setAnchor(
            top: topAnchor,
            leading: audioStateButton.trailingAnchor,
            bottom: bottomAnchor,
            width: frame.height * 2
        )
    }
    
    private func updateAudioPlayImage(audioPlayState state: AudioPlayState) {
        switch state {
        case .play:
            audioStateButton.setImage(playImage, for: .normal)
            audioPlayer?.play()
            audioPlayState = .play
        case .pause:
            audioStateButton.setImage(pauseImage, for: .normal)
            audioPlayer?.pause()
            audioPlayState = .pause
        }
    }
    
    private func playAudioProgress() {
        audioProgressView.setAnchor(
            top: topAnchor,
            leading: leadingAnchor,
            bottom: bottomAnchor,
            width: (audioPlayer?.currentTime / audioPlayer?.duration) * frame.width
        )
    }
}

extension AudioPlayerView: AVAudioPlayerDelegate {
    nonisolated public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        MHLogger.debug("audio player finished")
    }
}
