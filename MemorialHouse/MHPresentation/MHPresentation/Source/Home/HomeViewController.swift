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
        flowLayout.itemSize = .init(width: cellWidth, height: 210)
        flowLayout.minimumLineSpacing = 40
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
    private var currentCategoryIndex = 0 {
        didSet {
            currentCategoryLabel.text = viewModel.categories[currentCategoryIndex]
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
        input.send(.viewDidLoad)
        configureAddSubView()
        configureAction()
        configureConstraints()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Setup & Configuration
    private func setup() {
        view.backgroundColor = .baseBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            BookCollectionViewCell.self,
            forCellWithReuseIdentifier: BookCollectionViewCell.identifier
        )
        categorySelectButton.setImage(.dropDown, for: .normal)
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output.sink { [weak self] event in
            guard let self else { return }
            switch event {
            case .fetchedMemorialHouseAndCategory:
                self.updateMemorialHouse()
            case .filteredBooks:
                self.collectionView.reloadData()
            case .fetchedFailure(let errorMessage):
                self.handleError(with: errorMessage)
            }
        }.store(in: &cancellables)
    }
    
    private func updateMemorialHouse() {
        // 네비게이션 타이틀 설정
        let houseName = viewModel.houseName
        navigationBar.configureTitle(with: houseName)
        
        // 카테고리 설정
        currentCategoryLabel.text = viewModel.categories.first
        
        // BoockCover 설정
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
        categorySelectButton.addAction(UIAction { [weak self] _ in
            do {
                guard let self else { return }
                let categoryViewModelFactory = try DIContainer.shared.resolve(CategoryViewModelFactory.self)
                let categoryViewModel = categoryViewModelFactory.make()
                categoryViewModel.setup(categories: self.viewModel.categories, categoryIndex: self.currentCategoryIndex)
                let categoryViewController = CategoryViewController(viewModel: categoryViewModel)
                categoryViewController.delegate = self
                let navigationController = UINavigationController(rootViewController: categoryViewController)
                
                if let sheet = navigationController.sheetPresentationController {
                    sheet.detents = [.custom(identifier: .categorySheet) { _ in
                        categoryViewController.calculateSheetHeight()
                    }]
                }
                
                self.present(navigationController, animated: true)
            } catch let error as MHError {
                MHLogger.error(error.description)
            } catch {
                MHLogger.error(error.localizedDescription)
            }
        }, for: .touchUpInside)
        
        makingBookFloatingButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let bookCreationViewController = BookCreationViewController(viewModel: BookCreationViewModel())
            self.navigationController?.pushViewController(bookCreationViewController, animated: true)
        }, for: .touchUpInside)
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
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        // TODO: 책 펼치기 로직
    }
    
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
        cell.configure(
            title: bookCover.title,
            bookCoverImage: bookCover.color.image,
            targetImage: UIImage(systemName: "person")!,
            isLike: bookCover.favorite,
            houseName: viewModel.houseName
        )
        
        return cell
    }
}

extension HomeViewController: CategoryViewControllerDelegate {
    func categoryViewController(_ categoryViewController: CategoryViewController, didSelectCategoryIndex index: Int) {
        currentCategoryIndex = index
        input.send(.selectedCategory(index: index))
    }
}
