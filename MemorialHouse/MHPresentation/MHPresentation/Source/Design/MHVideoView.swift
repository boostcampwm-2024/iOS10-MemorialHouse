import AVKit
import MHCore
import MHDomain

final class MHVideoView: UIView {
    // MARK: - Property
    private let playerViewController: AVPlayerViewController

    // MARK: - Initializer
    init() {
        self.playerViewController = AVPlayerViewController()
        
        super.init(frame: .zero)
        configureConstraint()
    }

    required init?(coder: NSCoder) {
        self.playerViewController = AVPlayerViewController()
        
        super.init(coder: coder)
        configureConstraint()
    }
    
    // MARK: - Configuration
    func configurePlayer(player: AVPlayer) {
        playerViewController.player = player
        playerViewController.showsPlaybackControls = true
    }
    
    private func configureConstraint() {
        addSubview(playerViewController.view)
        playerViewController.view.fillSuperview()
    }
}

extension MHVideoView: @preconcurrency MediaAttachable {
    func configureSource(with mediaDescription: MediaDescription, data: Data) {
        MHLogger.debug(#function)
    }
    
    func configureSource(with mediaDescription: MediaDescription, url: URL) {
        let player = AVPlayer(url: url)
        configurePlayer(player: player)
    }
}
