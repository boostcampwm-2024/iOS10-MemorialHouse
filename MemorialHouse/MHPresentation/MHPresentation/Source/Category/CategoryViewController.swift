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
        
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        46
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        5
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.identifier,
            for: indexPath
        ) as? CategoryTableViewCell else { return UITableViewCell() }
        
        let category = viewModel.dummyData[indexPath.row]
        cell.configure(category: category, isSelected: true)
        
        return cell
    }
}
