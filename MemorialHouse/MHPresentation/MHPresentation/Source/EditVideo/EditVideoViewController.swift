import AVKit

final class EditVideoViewController: UIViewController {
    // MARK: - Properties
    private let videoURL: URL
    private let completion: (URL) -> Void
    private let videoView: MHVideoView

    // MARK: - Initializer
    init(videoURL: URL, videoSelectCompletionHandler: @escaping (URL) -> Void) {
        self.videoURL = videoURL
        self.completion = videoSelectCompletionHandler
        let player = AVPlayer(url: videoURL)
        self.videoView = MHVideoView(player: player)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.videoURL = URL(fileURLWithPath: "")
        self.completion = { _ in }
        let player = AVPlayer(url: videoURL)
        self.videoView = MHVideoView(player: player)
        
        super.init(coder: coder)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAudioSessionForPlayback()
        setup()
        configureVideoView()
        configureNavigationBar()

        // 부모 컨트롤러에 AVPlayerViewController 연결
        videoView.attachPlayerViewController(to: self)
    }
    
    // MARK: - Setup & Configuration
    private func setup() {
        view.backgroundColor = .baseBackground
    }
    
    private func configureVideoView() {
        view.addSubview(videoView)
        videoView.fillSuperview()
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ownglyphBerry(size: 17),
            .foregroundColor: UIColor.black
        ]
        navigationItem.title = "동영상 업로드" // TODO: 동영상 편집 로직 변경 필요
        
        // 공통 스타일 정의
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ownglyphBerry(size: 17),
            .foregroundColor: UIColor.mhTitle
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ownglyphBerry(size: 17),
            .foregroundColor: UIColor.mhTitle
        ]
        
        // 좌측 편집 버튼
        let editButton = UIBarButtonItem(
            title: "취소",
            normal: normalAttributes,
            selected: selectedAttributes
        ) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        navigationItem.leftBarButtonItem = editButton
        
        // 우측 추가 버튼
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "추가",
            normal: normalAttributes,
            selected: selectedAttributes
        ) { [weak self] in
            self?.completion(self?.videoURL ?? URL(fileURLWithPath: ""))
            if let navigationController = self?.navigationController {
                navigationController.popViewController(animated: false)
                navigationController.popViewController(animated: true)
            }
        }
    }
}