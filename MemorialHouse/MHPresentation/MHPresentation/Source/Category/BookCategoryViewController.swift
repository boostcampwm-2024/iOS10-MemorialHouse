import Combine
import MHCore
import MHFoundation
import UIKit

@MainActor
protocol BookCategoryViewControllerDelegate: AnyObject {
    func categoryViewController(
        _ categoryViewController: BookCategoryViewController,
        didSelectCategory category: String
    )
}

final class BookCategoryViewController: UIViewController {
    // MARK: - UI Components
    private let categoryTableView = UITableView()
    
    // MARK: - Properties
    weak var delegate: BookCategoryViewControllerDelegate?
    private let viewModel: BookCategoryViewModel
    private let input = PassthroughSubject<BookCategoryViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(viewModel: BookCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        guard let viewModelFactory = try? DIContainer.shared.resolve(BookCategoryViewModelFactory.self) else {
            return nil
        }
        self.viewModel = viewModelFactory.make()
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
            BookCategoryTableViewCell.self,
            forCellReuseIdentifier: BookCategoryTableViewCell.identifier
        )
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output.sink { [weak self] event in
            switch event {
            case .createdCategory, .updatedCategory, .fetchCategories, .deletedCategory:
                self?.categoryTableView.reloadData()
            case .failed(let errorMessage):
                self?.handleError(with: errorMessage)
            }
        }.store(in: &cancellables)
    }
    
    private func handleError(with errorMessage: String) {
        let alertController = UIAlertController(
            title: "에러",
            message: errorMessage,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "확인", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
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
                    guard let newText, !newText.isEmpty else {
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

extension BookCategoryViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let selectedCategory = viewModel.categories[indexPath.row]
        delegate?.categoryViewController(self, didSelectCategory: selectedCategory.name)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        BookCategoryTableViewCell.height
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
                    textField.text = self.viewModel.categories[indexPath.row].name
                },
                confirmHandler: { [weak self] newText in
                    guard let self, let newText = newText, !newText.isEmpty else {
                        MHLogger.error("수정할 카테고리 이름이 유효하지 않습니다.")
                        completion(false)
                        return
                    }
                    self.input.send(.updateCategory(index: indexPath.row, text: newText))
                    completion(true)
                }
            )
            
            self.present(alert, animated: true)
        }
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "삭제"
        ) { [weak self] _, _, completion in
            guard let self = self else { return }
            
            let alert = UIAlertController(
                title: "카테고리 삭제",
                message: "\"\(self.viewModel.categories[indexPath.row])\"을(를) 삭제하시겠습니까?",
                confirmTitle: "삭제",
                cancelTitle: "취소"
            ) { [weak self] _ in
                guard let self else { return }
                self.input.send(.deleteCategory(index: indexPath.row))
                completion(true)
            }
            
            self.present(alert, animated: true)
        }
        
        return UISwipeActionsConfiguration(
            actions: [deleteAction, editAction]
        )
    }
}

extension BookCategoryViewController: UITableViewDataSource {
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
            withIdentifier: BookCategoryTableViewCell.identifier,
            for: indexPath
        ) as? BookCategoryTableViewCell else { return UITableViewCell() }
        
        let isSelected = viewModel.categories[indexPath.row].name == viewModel.currentCategoryName
        cell.configure(category: viewModel.categories[indexPath.row].name, isSelected: isSelected)
        cell.backgroundColor = .baseBackground
        
        return cell
    }
}
