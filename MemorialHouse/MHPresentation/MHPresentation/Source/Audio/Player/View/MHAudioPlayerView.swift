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
    nonisolated(unsafe) var audioPlayer: AVAudioPlayer?
    var audioPlayState: AudioPlayState = .pause {
        didSet {
            switch audioPlayState {
            case .play:
                startTimer()
            case .pause:
                stopTimer()
            }
        }
    }
    var timer: Timer?
    
    // MARK: - ViewComponent
    let backgroundBorderView: UIView = {
        let backgroundBorderView = UIView()
        backgroundBorderView.backgroundColor = .baseBackground
        backgroundBorderView.layer.borderWidth = 4
        backgroundBorderView.layer.cornerRadius = 25
        backgroundBorderView.layer.borderColor = UIColor.captionPlaceHolder.cgColor
        
        return backgroundBorderView
    }()
    let audioProgressView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .mhPink
//        backgroundView.layer.borderWidth = 4
        backgroundView.layer.cornerRadius = 21
//        backgroundView.layer.borderColor = UIColor.baseBackground.cgColor
        
        return backgroundView
    }()
    var progressViewWidthConstraint: NSLayoutConstraint?
    var progressViewConstraints: [NSLayoutConstraint] = []
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
        label.font = UIFont.ownglyphBerry(size: 21)
        label.textAlignment = .left
        label.textColor = .dividedLine
        
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
        backgroundColor = .baseBackground
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
        addSubview(backgroundBorderView)
        addSubview(audioProgressView)
        addSubview(audioStateButton)
        addSubview(audioPlayTimeLabel)
    }
    
    private func configureContstraints() {
        backgroundBorderView.setAnchor(
            top: topAnchor, constantTop: 25,
            leading: leadingAnchor,
            bottom: bottomAnchor, constantBottom: 25,
            trailing: trailingAnchor
        )
        
        audioProgressView.translatesAutoresizingMaskIntoConstraints = false
        progressViewWidthConstraint = audioProgressView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            audioProgressView.topAnchor.constraint(equalTo: topAnchor, constant: 29),
            audioProgressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            audioProgressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -29),
            progressViewWidthConstraint ?? audioProgressView.widthAnchor.constraint(equalToConstant: 0)
        ])
        
        audioStateButton.setAnchor(
            top: topAnchor, constantTop: 25,
            leading: leadingAnchor,
            bottom: bottomAnchor, constantBottom: 25,
            width: 50
        )
        
        audioPlayTimeLabel.setAnchor(
            top: topAnchor, constantTop: 25,
            leading: audioStateButton.trailingAnchor,
            bottom: bottomAnchor, constantBottom: 25,
            width: 100
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
        }
    }
    
    private func updatePlayAudioProgress() {
        guard let audioPlayer else { return }
        let width = ceil(Float(audioPlayer.currentTime) / Float(audioPlayer.duration) * Float(299))
        
        progressViewWidthConstraint?.constant = CGFloat(width)
        UIView.animate(withDuration: 0) {
            self.layoutIfNeeded()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let audioPlayer = self?.audioPlayer else { return }
            Task { @MainActor in
                if audioPlayer.isPlaying {
                    self?.updatePlayAudioProgress()
                } else {
                    
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
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
            
            stopTimer()
            
            progressViewWidthConstraint?.constant = CGFloat(290)
            UIView.animate(withDuration: 0) {
                self.layoutIfNeeded()
            }
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
