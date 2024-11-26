import UIKit

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
        // TODO: didSelectRowAt 구현
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
        content.attributedText = NSAttributedString(
            string: viewModel.tableViewDataSource[indexPath.row],
            attributes: [.font: UIFont.ownglyphBerry(size: 17),
                         .foregroundColor: UIColor.mhTitle]
        )
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
    }
}
