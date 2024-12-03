import AVKit

final class MHVideoView: UIView {
    private let playerViewController: AVPlayerViewController

    init(player: AVPlayer) {
        self.playerViewController = AVPlayerViewController()
        
        super.init(frame: .zero)
        setupPlayer(player: player)
    }

    required init?(coder: NSCoder) {
        self.playerViewController = AVPlayerViewController()
        
        super.init(coder: coder)
    }
        
    private func setupPlayer(player: AVPlayer) {
        playerViewController.player = player
        playerViewController.showsPlaybackControls = true
    }

    func attachPlayerViewController(to parentViewController: UIViewController) {
        parentViewController.addChild(playerViewController)
        addSubview(playerViewController.view)
        
        playerViewController.view.frame = bounds
        playerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerViewController.didMove(toParent: parentViewController)
    }

    func play() {
        playerViewController.player?.play()
    }

    func pause() {
        playerViewController.player?.pause()
    }

    func seek(to time: CMTime) {
        playerViewController.player?.seek(to: time)
    }
}
