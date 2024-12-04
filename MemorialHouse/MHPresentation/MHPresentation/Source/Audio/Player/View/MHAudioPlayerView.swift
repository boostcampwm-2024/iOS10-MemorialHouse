import UIKit
import Combine
import AVFAudio
import MHCore
import MHDomain

final class MHAudioPlayerView: UIView {
    // MARK: - Property
    // data bind
    private var viewModel: AudioPlayerViewModel?
    private let input = PassthroughSubject<AudioPlayerViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    // audio
    private nonisolated(unsafe) var audioPlayer: AVAudioPlayer?
    private var audioPlayState: AudioPlayState = .pause {
        didSet {
            switch audioPlayState {
            case .play:
                startTimer()
            case .pause:
                stopTimer()
            }
        }
    }
    private var timer: Timer?
    
    // MARK: - ViewComponent
    private let backgroundBorderView: UIView = {
        let backgroundBorderView = UIView()
        backgroundBorderView.backgroundColor = .baseBackground
        backgroundBorderView.layer.borderWidth = 3
        backgroundBorderView.layer.cornerRadius = 25
        backgroundBorderView.layer.borderColor = UIColor.captionPlaceHolder.cgColor
        
        return backgroundBorderView
    }()
    private let audioProgressView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .mhPink
        backgroundView.layer.cornerRadius = 21
        
        return backgroundView
    }()
    private var progressViewWidthConstraint: NSLayoutConstraint?
    private var progressViewConstraints: [NSLayoutConstraint] = []
    private let audioStateButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill")?
            .withTintColor(.captionPlaceHolder, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    private let playImage = UIImage(systemName: "play.fill")?
        .withTintColor(.captionPlaceHolder, renderingMode: .alwaysOriginal)
    private let pauseImage = UIImage(systemName: "pause.fill")?
        .withTintColor(.captionPlaceHolder, renderingMode: .alwaysOriginal)
    private let audioPlayTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = UIFont.ownglyphBerry(size: 21)
        label.textAlignment = .left
        label.textColor = .dividedLine
        
        return label
    }()
    private var playerWidth: CGFloat = 0
    
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
        progressViewWidthConstraint = audioProgressView.widthAnchor.constraint(equalToConstant: frame.width - 9)
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
            audioStateButton.setImage(playImage, for: .normal)
            audioPlayer?.pause()
            audioPlayState = .pause
        case .pause:
            audioStateButton.setImage(pauseImage, for: .normal)
            audioPlayer?.play()
            audioPlayState = .play
        }
    }
    
    private func updatePlayAudioProgress() {
        guard let audioPlayer else { return }
        let width = ceil(Float(audioPlayer.currentTime) / Float(audioPlayer.duration) * Float(frame.width))
        
        progressViewWidthConstraint?.constant = CGFloat(width)
        self.layoutIfNeeded()
        let seconds = ceil(Double(audioPlayer.currentTime))
        self.setTimeLabel(seconds: Int(seconds))
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let audioPlayer = self?.audioPlayer else { return }
            Task { @MainActor in
                if audioPlayer.isPlaying {
                    self?.updatePlayAudioProgress()
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
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.audioPlayState = .pause
            self.audioStateButton.setImage(playImage, for: .normal)
            
            stopTimer()
            
            progressViewWidthConstraint?.constant = CGFloat(frame.width - 9)
            self.layoutIfNeeded()
        }
    }
}

extension MHAudioPlayerView: @preconcurrency MediaAttachable {
    func configureSource(with mediaDescription: MediaDescription, data: Data) {
        audioPlayer = try? AVAudioPlayer(data: data)
        guard let audioPlayer else { return }
        audioPlayer.delegate = self
        self.setTimeLabel(seconds: Int(ceil(Double(audioPlayer.duration))))
    }
    
    func configureSource(with mediaDescription: MediaDescription, url: URL) {
        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        guard let audioPlayer else { return }
        audioPlayer.delegate = self
        self.setTimeLabel(seconds: Int(ceil(Double(audioPlayer.duration))))
    }
}
