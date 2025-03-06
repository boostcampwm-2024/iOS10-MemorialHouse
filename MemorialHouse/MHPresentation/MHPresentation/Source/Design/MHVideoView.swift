import AVKit
import MHCore
import MHDomain

final class MHVideoView: UIView {
    // MARK: - Property
    let playerViewController = AVPlayerViewController()
    private var timeControlStatusObservation: NSKeyValueObservation?

    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureConstraint()
        NotificationCenter.default.addObserver(self, selector: #selector(stopPlayer), name: .mediaPlaybackStarted, object: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureConstraint()
        NotificationCenter.default.addObserver(self, selector: #selector(stopPlayer), name: .mediaPlaybackStarted, object: nil)
    }
    
    // MARK: - Configuration
    func configurePlayer(player: AVPlayer) {
        playerViewController.player = player
        playerViewController.showsPlaybackControls = true
        timeControlStatusObservation = player.observe(\.timeControlStatus, options: [.new]) { player, change in
            switch player.timeControlStatus {
            case .playing:
                NotificationCenter.default.post(name: .mediaPlaybackStarted, object: self)
            default:
                break
            }
        }
    }
    
    private func configureConstraint() {
        addSubview(playerViewController.view)
        playerViewController.view.fillSuperview()
    }
    
    @objc
    private func stopPlayer(_ notification: NSNotification) {
        guard notification.object as? MHVideoView !== self else { return }
        playerViewController.player?.pause()
    }
    
    // MARK: - LifeCycle
    override func didMoveToWindow() {
        super.didMoveToSuperview()
        
        if window == nil {
            playerViewController.player?.pause()
        }
    }
    
    deinit {
        timeControlStatusObservation?.invalidate()
    }
}

extension MHVideoView: MediaAttachable {
    func configureSource(with mediaDescription: MediaDescription, data: Data) {
        let player = AVPlayer()
        configurePlayer(player: player)
    }
    
    func configureSource(with mediaDescription: MediaDescription, url: URL) {
        let player = AVPlayer(url: url)
        configurePlayer(player: player)
    }
}
