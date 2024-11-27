import UIKit

final class BookViewController: UIViewController {
    // MARK: - UI Components
    private let pageViewController = UIPageViewController(
        transitionStyle: .pageCurl,
        navigationOrientation: .horizontal
    )
    
    // MARK: - Property
    private let viewModel: BookViewModel
    
    // MARK: - Initialize
    init(bookTitle: String, viewModel: BookViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        title = bookTitle
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = BookViewModel()
        super.init(nibName: nil, bundle: nil)
        
        title = "책 이름"
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureNavigationBar()
        configureConstraints()
        configurePageViewController()
    }
    
    // MARK: - Setup & Configure
    private func setup() {
        view.backgroundColor = .baseBackground
        addChild(pageViewController)
        pageViewController.delegate = self
        pageViewController.dataSource = self
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ownglyphBerry(size: 17),
            .foregroundColor: UIColor.mhTitle
        ]
        
        // 공통 스타일 정의
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ownglyphBerry(size: 17),
            .foregroundColor: UIColor.mhTitle
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ownglyphBerry(size: 17),
            .foregroundColor: UIColor.mhTitle
        ]
        
        // 왼쪽 닫기 버튼
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "닫기",
            normal: normalAttributes,
            selected: selectedAttributes
        ) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        // 오른쪽 책 속지 수정 버튼
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "수정",
            normal: normalAttributes,
            selected: selectedAttributes
        ) { [weak self] in
            // TODO: - 추후 책 속지 수정 페이지로 넘어가는 로직 필요
        }
    }
    
    private func configureConstraints() {
        view.addSubview(pageViewController.view)
        pageViewController.view.fillSuperview()
    }
    
    // MARK: - Set PageviewController
    private func configurePageViewController() {
        guard let startViewController = makeNewPageViewController(index: 0) else { return }
        let viewControllers = [startViewController]
        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
    }
    
    private func makeNewPageViewController(index: Int) -> PageViewController? {
        // TODO: - 로직 수정 필요
        return PageViewController(viewModel: PageViewModel(index: index))
    }
}

// MARK: - UIPageViewControllerDelegate
extension BookViewController: UIPageViewControllerDelegate {
    // TODO: - Page transition 감지
}

// MARK: - UIPageViewControllerDataSource
extension BookViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let targetViewController = viewController as? PageViewController else { return nil }
        let pageIndex = targetViewController.getPageIndex()
        
        return pageIndex == 0
        ? nil
        : makeNewPageViewController(index: pageIndex - 1)
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let targetViewController = viewController as? PageViewController else { return nil }
        let pageIndex = targetViewController.getPageIndex()
        
        return pageIndex == viewModel.pageList.count - 1
        ? nil
        : makeNewPageViewController(index: pageIndex + 1)
    }
}
