import Combine
import MHFoundation
import UIKit

@MainActor
protocol CategoryViewControllerDelegate: AnyObject {
    func categoryViewController(_ categoryViewController: CategoryViewController, didSelectCategoryIndex index: Int)
}

final class CategoryViewController: UIViewController {
    // MARK: - UI Components
    private let categoryTableView = UITableView()
    
    // MARK: - Properties
    weak var delegate: CategoryViewControllerDelegate?
    private let viewModel: CategoryViewModel
    private let input = PassthroughSubject<CategoryViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = CategoryViewModel(categories: ["전체", "즐겨찾기"], currentCategoryIndex: 0)
        super.init(coder: coder)
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
        configureNavigationBar()
        configureConstraints()
    }
    
    func calculateSheetHeight() -> CGFloat {
        let cellHeight = CategoryTableViewCell.height
        let itemCount = CGFloat(viewModel.categories.count)
        return (cellHeight * itemCount) + Constant.navigationBarHeight
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
            case .addedCategory, .updatedCategory, .deletedCategory:
                self?.categoryTableView.reloadData()
            }
        }.store(in: &cancellables)
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ownglyphBerry(size: 17),
            .foregroundColor: UIColor.black
        ]
        navigationItem.title = "카테고리"
        
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
            title: "편집",
            normal: normalAttributes,
            selected: selectedAttributes
        ) { [weak self] in
            guard let self else { return }
            let isEditing = self.categoryTableView.isEditing
            self.categoryTableView.setEditing(!isEditing, animated: true)
            
            // 버튼 타이틀 업데이트
            let newTitle = isEditing ? "편집" : "완료"
            self.navigationItem.leftBarButtonItem?.title = newTitle
        }
        navigationItem.leftBarButtonItem = editButton
        
        // 우측 추가 버튼
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "추가",
            normal: normalAttributes,
            selected: selectedAttributes
        ) { [weak self] in
            guard let self else { return }
            
            let alert = UIAlertController(
                title: "카테고리 추가",
                message: "새로운 카테고리를 입력해주세요.",
                textFieldConfiguration: { textField in
                    textField.placeholder = "카테고리 이름"
                },
                confirmHandler: { [weak self] newText in
                    guard let newText = newText, !newText.isEmpty else {
                        MHLogger.error("입력한 카테고리 이름이 유효하지 않습니다.")
                        return
                    }
                    self?.input.send(.addCategory(text: newText))
                }
            )
            
            self.present(alert, animated: true)
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
        delegate?.categoryViewController(self, didSelectCategoryIndex: indexPath.row)
        dismiss(animated: true, completion: nil)
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
            guard let self else { return }
            let alert = UIAlertController(
                title: "카테고리 수정",
                message: "수정할 카테고리 이름을 입력해주세요.",
                textFieldConfiguration: { textField in
                    textField.placeholder = "카테고리 이름"
                    textField.text = self.viewModel.categories[indexPath.row]
                },
                confirmHandler: { [weak self] newText in
                    guard let newText = newText, !newText.isEmpty else {
                        print("수정할 카테고리 이름이 유효하지 않습니다.")
                        return
                    }
                    self?.input.send(.updateCategory(index: indexPath.row, text: newText))
                    completion(true)
                }
            )
            
            self.present(alert, animated: true)
        }
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "삭제"
        ) { [weak self] _, _, completion in
            guard let self else { return }
            
            // 편의 이니셜라이저를 활용한 AlertController 생성
            let alert = UIAlertController(
                title: "카테고리 삭제",
                message: "\"\(self.viewModel.categories[indexPath.row])\"을(를) 삭제하시겠습니까?",
                confirmTitle: "삭제",
                cancelTitle: "취소",
                confirmHandler: { [weak self] _ in
                    self?.input.send(.deleteCategory(index: indexPath.row))
                    completion(true)
                }
            )
            
            self.present(alert, animated: true)
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
        viewModel.categories.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.identifier,
            for: indexPath
        ) as? CategoryTableViewCell else { return UITableViewCell() }
        let isSelected = indexPath.row == viewModel.currentCategoryIndex
        cell.configure(category: viewModel.categories[indexPath.row], isSelected: isSelected)
        cell.backgroundColor = .baseBackground
        
        return cell
    }
}
