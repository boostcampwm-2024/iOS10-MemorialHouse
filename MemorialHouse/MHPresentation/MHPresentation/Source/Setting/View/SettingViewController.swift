import MHCore
import UIKit
import SafariServices

final class SettingViewController: UIViewController {
    // MARK: - UI Component
    private let settingTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 60
        tableView.backgroundColor = .clear
        
        return tableView
    }()

    // MARK: - Property
    private let viewModel: SettingViewModel
    
    // MARK: - Initializer
    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = SettingViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        configureNavigationBar()
        configureConstraints()
    }
    
    // MARK: - Setup & Configures
    private func setup() {
        view.backgroundColor = .baseBackground
        settingTableView.dataSource = self
        settingTableView.delegate = self
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        // 공통 스타일 정의
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ownglyphBerry(size: 17),
            .foregroundColor: UIColor.mhTitle
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ownglyphBerry(size: 17),
            .foregroundColor: UIColor.mhTitle
        ]
        
        // 네비게이션 왼쪽 아이템
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "뒤로",
            normal: normalAttributes,
            selected: selectedAttributes
        ) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        // 네비게이션 타이틀
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ownglyphBerry(size: 17),
            .foregroundColor: UIColor.mhTitle
        ]
        navigationItem.title = "설정"
    }
    
    private func configureConstraints() {
        view.addSubview(settingTableView)
        settingTableView.fillSuperview()
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: // 서비스 이용 약관
            openSafari(urlString: "https://kyxxn.notion.site/3eb0620fd9f242f297fc3f6c8d022978?pvs=4")
        case 1: // 개인정보 처리 방침
            openSafari(urlString: "https://kyxxn.notion.site/3a14a15e528f4dc9b1e5b1a9599778af?pvs=4")
        case 2: // 불편신고 및 개선요청
            sendMailToReport()
        case 3: // 자주 묻는 질문
            openSafari(urlString: "https://kyxxn.notion.site/FAQ-7cae87a10cc04f3b9205c10930998ec1?pvs=4")
        default:
            break
        }
    }
    
    private func openSafari(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    private func sendMailToReport() {
        let address = "k264535@gmail.com"
        let subject = "[기록소] 앱 불편신고 및 개선요청"

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = address
        components.queryItems = [
              URLQueryItem(name: "subject", value: subject)
        ]

        guard let url = components.url else {
            MHLogger.error("mailto URL 만들기 실패")
            return
        }

        UIApplication.shared.open(url) { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableViewDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        let cellInformation = viewModel.tableViewDataSource[indexPath.row]
        content.attributedText = NSAttributedString(
            string: cellInformation,
            attributes: [.font: UIFont.ownglyphBerry(size: 17),
                         .foregroundColor: UIColor.mhTitle]
        )
        if cellInformation == viewModel.tableViewDataSource.last {
            content.secondaryAttributedText = NSAttributedString(
                string: "v \(viewModel.appVersion ?? "0.0")",
                attributes: [.font: UIFont.ownglyphBerry(size: 15),
                             .foregroundColor: UIColor.lightGray]
            )
        }
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
    }
}
