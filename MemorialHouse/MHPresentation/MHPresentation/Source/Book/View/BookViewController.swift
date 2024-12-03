import MHCore
import MHDomain
import UIKit
import Combine

final class BookViewController: UIViewController {
    // MARK: - UI Component
    private let pageViewController = UIPageViewController(
        transitionStyle: .pageCurl,
        navigationOrientation: .horizontal
    )
    
    // MARK: - Properties
    private let viewModel: BookViewModel
    private let input = PassthroughSubject<BookViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    init(viewModel: BookViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        guard let viewModel = try? DIContainer.shared.resolve(BookViewModel.self) else { return nil }
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setup()
        configureNavigationBar()
        configureConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        input.send(.loadBook)
    }
    
    // MARK: - Binding
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
            switch event {
            case .setBookTitle(let bookTitle):
                self?.title = bookTitle
            case .loadFirstPage(let page):
                guard let page else { return }
                self?.configureFirstPageViewController(firstPage: page)
            case .moveToEdit(let bookID):
                self?.presentEditBookView(bookID: bookID)
            }
        }
        .store(in: &cancellables)
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
            self?.input.send(.editBook)
        }
    }
    
    private func configureConstraints() {
        view.addSubview(pageViewController.view)
        pageViewController.view.fillSuperview()
    }
    
    // MARK: - Set PageviewController
    private func configureFirstPageViewController(firstPage: Page) {
        guard let startViewController = makeNewPageViewController(page: firstPage) else { return }
        let viewControllers = [startViewController]
        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
    }
    
    private func makeNewPageViewController(page: Page) -> ReadPageViewController? {
        guard let readPageViewModelFactory = try? DIContainer.shared.resolve(ReadPageViewModelFactory.self) else {
            return nil
        }
        let readPageViewModel = readPageViewModelFactory.make(bookID: viewModel.identifier, page: page)
        
        return ReadPageViewController(viewModel: readPageViewModel)
    }
    
    // MARK: - PresentEditBookView
    private func presentEditBookView(bookID: UUID) {
        do {
            let editBookViewModelFactory = try DIContainer.shared.resolve(EditBookViewModelFactory.self)
            let editBookViewModel = editBookViewModelFactory.make(bookID: bookID)
            let editBookViewController = EditBookViewController(viewModel: editBookViewModel, mode: .modify)
            navigationController?.pushViewController(editBookViewController, animated: true)
        } catch {
            MHLogger.error(error)
        }
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
        guard let previousPage = viewModel.previousPage else { return nil }
        input.send(.loadPreviousPage)
        
        return makeNewPageViewController(page: previousPage)
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let nextPage = viewModel.nextPage else { return nil }
        input.send(.loadNextPage)
        
        return makeNewPageViewController(page: nextPage)
    }
}
