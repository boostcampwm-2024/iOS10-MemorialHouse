import UIKit
import MHCore
import MHFoundation

public final class HomeViewController: UIViewController {
    // MARK: - UI Components
    private let navigationBar = MHNavigationBar(title: "")
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
    private var floatingButtonBottomConstraint: NSLayoutConstraint?
    private var isFloatingButtonHidden = false
    
    // MARK: - Initializer
    public init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        let viewModelFactory = try! DIContainer.shared.resolve(HomeViewModelFactory.self)
        self.viewModel = viewModelFactory.make()
        super.init(coder: coder)
    }
    
    // MARK: - View LifeCycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
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
        currentCategoryLabel.text = "전체" // TODO: 카테고리 관리 필요
        categorySelectButton.setImage(.dropDown, for: .normal)
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
            let categoryViewModel = CategoryViewModel()
            let categoryViewController = CategoryViewController(viewModel: categoryViewModel)
            let navigationController = UINavigationController(rootViewController: categoryViewController)
            
            if let sheet = navigationController.sheetPresentationController {
                sheet.detents = [.custom(identifier: .categorySheet) { _ in
                    categoryViewController.calculateSheetHeight()
                }]
            }
            
            self?.present(navigationController, animated: true)
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
        0
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BookCollectionViewCell.identifier,
            for: indexPath
        ) as? BookCollectionViewCell else { return UICollectionViewCell() }
        // TODO: 데이터 넣기
        
        return cell
    }
}
