import Combine
import UIKit

final class CategoryViewController: UIViewController {
    // MARK: - UI Components
    private let categoryTableView = UITableView()
    
    // MARK: - Properties
    private let viewModel: CategoryViewModel
    private let input = PassthroughSubject<CategoryViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = CategoryViewModel()
        super.init(coder: coder)
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
        input.send(.viewDidLoad)
        configureNavigationBar()
        configureConstraints()
    }
    
    // MARK: - Setup & Configuration
    private func setup() {
        view.backgroundColor = .baseBackground
        categoryTableView.backgroundColor = .baseBackground
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.register(
            CategoryTableViewCell.self,
            forCellReuseIdentifier: CategoryTableViewCell.identifier
        )
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output.sink { [weak self] event in
            switch event {
            case .fetchedCategories:
                self?.categoryTableView.reloadData()
            }
        }.store(in: &cancellables)
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ownglyphBerry(size: 22),
            .foregroundColor: UIColor.black
        ]
        navigationItem.title = "카테고리"
        
        // 좌측 닫기 버튼
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "편집",
            fontSize: 22,
            color: .mhTitle
        ) { [weak self] in
            // TODO: 편집하기
            self?.categoryTableView.setEditing(true, animated: true)
        }
        
        // 우측 추가 버튼
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "추가",
            fontSize: 22,
            color: .mhTitle
        ) { [weak self] in
            // TODO: 로컬에 저장하고 테이블뷰에 추가하는 로직 필요
        }
    }
    
    private func configureConstraints() {
        view.addSubview(categoryTableView)
        categoryTableView.fillSuperview()
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        // TODO: 카테고리 선택 시 로직 필요
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        CategoryTableViewCell.height
    }
    
    func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath
    ) -> Bool {
        indexPath.row >= 2
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(
            style: .normal,
            title: "수정"
        ) { [weak self] _, _, completion in
            // TODO: 수정 로직
        }
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "삭제"
        ) { [weak self] _, _, completion in
            // TODO: 삭제 로직
        }
        
        return UISwipeActionsConfiguration(
            actions: [deleteAction, editAction]
        )
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.dummyData.count + 2
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.identifier,
            for: indexPath
        ) as? CategoryTableViewCell else { return UITableViewCell() }
        
        // TODO: 데이터 넣기
        switch indexPath.row {
        case 0:
            cell.configure(category: "전체", isSelected: true)
        case 1:
            cell.configure(category: "즐겨찾기", isSelected: false)
        default:
            let category = viewModel.dummyData[indexPath.row - 2]
            cell.configure(category: category, isSelected: false)
        }
        
        return cell
    }
}
