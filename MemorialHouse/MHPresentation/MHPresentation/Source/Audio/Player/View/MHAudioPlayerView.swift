import UIKit
import Combine
import AVFAudio
import MHCore
import MHDomain


final public class MHAudioPlayerView: UIView {
    // MARK: - Property
    // data bind
    private var viewModel: AudioPlayerViewModel?
    private let input = PassthroughSubject<AudioPlayerViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    // audio
    var audioPlayer: AVAudioPlayer?
    var audioPlayState: AudioPlayState = .pause
    
    // MARK: - ViewComponent
    let audioProgressView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .mhPink
        backgroundView.layer.cornerRadius = 5
        
        return backgroundView
    }()
    let audioStateButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
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
        super.init(frame: frame)
        
        setup()
        bind()
        configureAddSubview()
        configureContstraints()
        configureAddActions()
    }
    
    public required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
    
    // MARK: - setup
    private func setup() {
        backgroundColor = .blue
        layer.cornerRadius = 5
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playback, mode: .default, options: [])
        try? audioSession.setActive(true)
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
            top: topAnchor, constantTop: 10,
            leading: leadingAnchor,
            bottom: bottomAnchor, constantBottom: 10,
            width: 50
        )
        
        audioStateButton.setAnchor(
            top: topAnchor,
            leading: leadingAnchor,
            bottom: bottomAnchor,
            width: 80
        )
        
        audioPlayTimeLabel.setAnchor(
            top: topAnchor,
            leading: audioStateButton.trailingAnchor,
            bottom: bottomAnchor,
            width: 160
        )
    }
    
    private func configureAddActions() {
        audioStateButton.addAction(UIAction { [weak self] _ in
            guard let audioPlayState = self?.audioPlayState else { return }
            self?.updateAudioPlayImage(audioPlayState: audioPlayState)
            
            self?.input.send(.audioStateButtonTapped)
        }, for: .touchUpInside)
    }
    
    private func updateAudioPlayImage(audioPlayState state: AudioPlayState) {
        switch state {
        case .play:
            MHLogger.debug("pause")
            audioStateButton.setImage(playImage, for: .normal)
            audioPlayer?.pause()
            audioPlayState = .pause
        case .pause:
            audioStateButton.setImage(pauseImage, for: .normal)
            if audioPlayer?.play() == false {
                MHLogger.error("do not play")
            } else {
                MHLogger.debug("do play")
            }
            audioPlayState = .play
            
//            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
//                Task { @MainActor in
//                    guard let player = self?.audioPlayer else {
//                        print("audio player not init")
//                        return }
//                    print("Current playback time: \(player.currentTime) seconds")
//                    
//                }
//            }
        }
    }
    
    private func playAudioProgress() {
        audioProgressView.setAnchor(
            top: topAnchor,
            leading: leadingAnchor,
            bottom: bottomAnchor
            // TODO: - width
        )
    }
    
    private func setTimeLabel(seconds recordingSeconds: Int?) {
        guard let recordingSeconds = recordingSeconds else { return }
        let minutes = recordingSeconds / 60
        let seconds = recordingSeconds % 60
        audioPlayTimeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
}

extension MHAudioPlayerView: AVAudioPlayerDelegate {
    nonisolated public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        MHLogger.debug("audio player finished")
        
        Task { @MainActor in
            self.audioPlayState = .pause
            self.audioStateButton.setImage(playImage, for: .normal)
        }
    }
}

extension MHAudioPlayerView: @preconcurrency MediaAttachable {
    func configureSource(with mediaDescription: MediaDescription, data: Data) {
        
    }
    
    func configureSource(with mediaDescription: MediaDescription, url: URL) {
        MHLogger.debug("configure source \(url)")
        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        guard let audioPlayer else { return }
        audioPlayer.delegate = self
        self.setTimeLabel(seconds: Int(audioPlayer.duration.rounded()))
    }
}
