import UIKit
import MHDomain

public final class HomeViewController: UIViewController {
    // MARK: - Properties
    private let navigationBar: MHNavigationBar
    private let currentCategoryLabel = UILabel(style: .default)
    private let categorySelectButton = UIButton(type: .custom)
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let cellSize = (self.view.bounds.inset(by: self.view.safeAreaInsets).width - 80) / 2
        flowLayout.itemSize = .init(width: cellSize, height: 210)
        flowLayout.minimumLineSpacing = 40
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .baseBackground
        
        return collectionView
    }()
    private let viewModel: HomeViewModel
    
    // MARK: - Initializer
    public init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        self.navigationBar = MHNavigationBar(title: viewModel.houseName)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        guard let houseName = UserDefaults.standard.string(forKey: "houseName") else { return nil }
        self.viewModel = HomeViewModel(houseName: houseName)
        self.navigationBar = MHNavigationBar(title: viewModel.houseName)
        super.init(coder: coder)
    }
    
    // MARK: - View LifeCycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureAddSubView()
        configureConstraints()
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
        categorySelectButton.setLeading(anchor: currentCategoryLabel.trailingAnchor, constant: 8)
        categorySelectButton.setCenterY(view: currentCategoryLabel)
        categorySelectButton.setWidth(20)
    }
}

extension HomeViewController: UICollectionViewDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        // TODO: 책 펼치기 로직
    }
}

extension HomeViewController: UICollectionViewDataSource {
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.dummyBook.count
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BookCollectionViewCell.identifier,
            for: indexPath
        ) as? BookCollectionViewCell else { return UICollectionViewCell() }
        
        let book = viewModel.dummyBook[indexPath.row]
        cell.configure(
            title: book.title,
            bookCoverImage: book.bookColor.image,
            targetImage: .pinkBook,
            isLike: book.isLike,
            houseName: viewModel.houseName
        )
        
        return cell
    }
}
