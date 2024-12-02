import Combine
import UIKit
import MHCore
import MHFoundation

public final class HomeViewController: UIViewController {
    // MARK: - UI Components
    private let navigationBar = MHNavigationBar()
    private let currentCategoryLabel = UILabel(style: .header2)
    private let categorySelectButton = UIButton(type: .custom)
    private let makingBookFloatingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(.bookMake, for: .normal)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 8
        
        return button
    }()
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let cellWidth = (self.view.bounds.inset(by: self.view.safeAreaInsets).width - 80) / 2
        flowLayout.itemSize = .init(width: cellWidth, height: cellWidth * 1.5)
        flowLayout.minimumLineSpacing = 25
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 30, right: 20)
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .baseBackground
        
        return collectionView
    }()
    
    // MARK: - Properties
    private let viewModel: HomeViewModel
    private let input = PassthroughSubject<HomeViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var floatingButtonBottomConstraint: NSLayoutConstraint?
    private var isFloatingButtonHidden = false
    private var currentCategory = "전체" {
        didSet {
            currentCategoryLabel.text = currentCategory
        }
    }
    
    // MARK: - Initializer
    public init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        guard let viewModelFactory = try? DIContainer.shared.resolve(HomeViewModelFactory.self) else { return nil }
        self.viewModel = viewModelFactory.make()
        super.init(coder: coder)
    }
    
    // MARK: - View LifeCycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
        configureAddSubView()
        configureAction()
        configureConstraints()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        input.send(.loadAllBookCovers)
    }
    
    // MARK: - Setup & Configuration
    private func setup() {
        view.backgroundColor = .baseBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.register(
            BookCollectionViewCell.self,
            forCellWithReuseIdentifier: BookCollectionViewCell.identifier
        )
        currentCategoryLabel.text = currentCategory
        categorySelectButton.setImage(.dropDown, for: .normal)
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output.sink { [weak self] event in
            guard let self else { return }
            switch event {
            case .fetchedMemorialHouseName:
                self.updateMemorialHouse()
            case .fetchedAllBookCover, .filteredBooks, .dragAndDropFinished:
                self.collectionView.reloadData()
            case .fetchedFailure(let errorMessage):
                self.handleError(with: errorMessage)
            }
        }.store(in: &cancellables)
    }
    
    private func updateMemorialHouse() {
        let houseName = viewModel.houseName
        navigationBar.configureTitle(with: houseName)
        
        collectionView.reloadData()
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
    
    private func configureAddSubView() {
        view.addSubview(navigationBar)
        view.addSubview(currentCategoryLabel)
        view.addSubview(categorySelectButton)
        view.addSubview(collectionView)
        view.addSubview(makingBookFloatingButton)
    }
    
    private func configureAction() {
        // MARK: 카테고리 화면으로 전환 버튼
        // FIXME: Custom Sheet로 변경 필요
        categorySelectButton.addAction(UIAction { [weak self] _ in
            do {
                guard let self else { return }
                let categoryViewModelFactory = try DIContainer.shared.resolve(BookCategoryViewModelFactory.self)
                let categoryViewModel = categoryViewModelFactory.makeForHome()
                categoryViewModel.setup(currentCategory: self.currentCategory)
                let categoryViewController = BookCategoryViewController(viewModel: categoryViewModel)
                categoryViewController.delegate = self
                let navigationController = UINavigationController(rootViewController: categoryViewController)
                
                if let sheet = navigationController.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                }
                
                self.present(navigationController, animated: true)
            } catch let error as MHCoreError {
                MHLogger.error(error.description)
            } catch {
                MHLogger.error(error.localizedDescription)
            }
        }, for: .touchUpInside)
        
        makingBookFloatingButton.addAction(UIAction { [weak self] _ in
            self?.moveBookCoverViewController()
        }, for: .touchUpInside)
        
        navigationBar.configureSettingAction(action: UIAction { [weak self] _ in
            guard let self else { return }
            let settingViewModel = SettingViewModel()
            let settingViewController = SettingViewController(viewModel: settingViewModel)
            self.navigationController?.pushViewController(settingViewController, animated: true)
        })
    }
    
    private func moveBookCoverViewController(bookID: UUID? = nil) {
        if let bookID {
            // TODO: - Modify ViewModel 필요
        } else {
            let viewModelFactory = try? DIContainer.shared.resolve(CreateBookCoverViewModelFactory.self)
            let createBookCoverViewModel = viewModelFactory?.make(bookCount: viewModel.currentBookCovers.count)
            let bookCreationViewController = BookCoverViewController(createViewModel: createBookCoverViewModel)
            navigationController?.pushViewController(bookCreationViewController, animated: true)
        }
    }
    
    private func configureConstraints() {
        navigationBar.setAnchor(
            top: view.safeAreaLayoutGuide.topAnchor, constantTop: 20,
            leading: view.leadingAnchor, constantLeading: 24,
            trailing: view.trailingAnchor, constantTrailing: 24
        )
        currentCategoryLabel.setAnchor(
            top: navigationBar.bottomAnchor, constantTop: 16,
            leading: view.leadingAnchor, constantLeading: 28
        )
        collectionView.setAnchor(
            top: currentCategoryLabel.bottomAnchor, constantTop: 16,
            leading: view.leadingAnchor,
            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor
        )
        makingBookFloatingButton.setAnchor(
            trailing: view.trailingAnchor, constantTrailing: 24,
            width: 80,
            height: 80
        )
        floatingButtonBottomConstraint = makingBookFloatingButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -24
        )
        floatingButtonBottomConstraint?.isActive = true
        categorySelectButton.setLeading(anchor: currentCategoryLabel.trailingAnchor, constant: 8)
        categorySelectButton.setCenterY(view: currentCategoryLabel)
        categorySelectButton.setWidth(20)
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if contentHeight > height {
            if offsetY > contentHeight - height {
                hideFloatingButton()
            } else {
                showFloatingButton()
            }
        } else {
            showFloatingButton()
        }
    }
    
    private func hideFloatingButton() {
        guard let floatingButtonBottomConstraint,
              !isFloatingButtonHidden else { return }
        isFloatingButtonHidden = true
        floatingButtonBottomConstraint.constant = 120
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    private func showFloatingButton() {
        guard let floatingButtonBottomConstraint,
              isFloatingButtonHidden else { return }
        isFloatingButtonHidden = false
        floatingButtonBottomConstraint.constant = -24
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.currentBookCovers.count
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BookCollectionViewCell.identifier,
            for: indexPath
        ) as? BookCollectionViewCell else { return UICollectionViewCell() }
        // TODO: Image Loader 필요 & 메모리 캐싱 필요
        
        let bookCover = viewModel.currentBookCovers[indexPath.item]
        cell.configureCell(
            id: bookCover.id,
            title: bookCover.title,
            bookCoverImage: bookCover.color.image,
            targetImage: UIImage(systemName: "person")!,
            isLike: bookCover.favorite,
            houseName: viewModel.houseName
        )
        cell.configureButtonAction(
            bookCoverAction: { [weak self] in
                self?.bookCoverTapped(indexPath: indexPath)
            },
            likeButtonAction: { [weak self] in
                self?.input.send(.likeButtonTapped(bookId: bookCover.id))
            },
            dropDownButtonEditAction: { [weak self] in
                self?.moveBookCoverViewController(bookID: bookCover.id)
            },
            dropDownButtonDeleteAction: { [weak self] in
                self?.input.send(.deleteBookCover(bookId: bookCover.id))
            }
        )
        
        return cell
    }
    
    private func bookCoverTapped(indexPath: IndexPath) {
        let bookID = viewModel.currentBookCovers[indexPath.row].id
        guard let bookViewModelFactory = try? DIContainer.shared.resolve(BookViewModelFactory.self) else {
            return
        }
        let bookViewModel = bookViewModelFactory.make(bookID: bookID)
        let bookViewController = BookViewController(viewModel: bookViewModel)
        navigationController?.pushViewController(bookViewController, animated: true)
    }
}

// MARK: - UICollectionViewDragDelegate
extension HomeViewController: UICollectionViewDragDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        itemsForBeginning session: any UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        return [dragItem]
    }
}

// MARK: - UICollectionViewDropDelegate
extension HomeViewController: UICollectionViewDropDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        guard collectionView.hasActiveDrag else { return UICollectionViewDropProposal(operation: .forbidden) }
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        performDropWith coordinator: UICollectionViewDropCoordinator
    ) {
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row - 1, section: 0)
        }
        
        moveItems(
            coordinator: coordinator,
            destinationIndexPath: destinationIndexPath,
            collectionView: collectionView
        )
    }
    
    private func moveItems(
        coordinator: UICollectionViewDropCoordinator,
        destinationIndexPath: IndexPath,
        collectionView: UICollectionView
    ) {
        guard
            coordinator.proposal.operation == .move,
            let item = coordinator.items.first,
            let sourceIndexPath = item.sourceIndexPath
        else { return }
        
        collectionView.performBatchUpdates { [weak self] in
            guard let self else { return }
            input.send(
                .dragAndDropBookCover(
                    currentIndex: sourceIndexPath.item,
                    destinationIndex: destinationIndexPath.item
                )
            )
            
            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [destinationIndexPath])
        }
    }
}

// MARK: - BookCategoryViewControllerDelegate
extension HomeViewController: BookCategoryViewControllerDelegate {
    func categoryViewController(
        _ categoryViewController: BookCategoryViewController,
        didSelectCategory category: String
    ) {
        currentCategory = category
        input.send(.selectedCategory(category: category))
    }
}
