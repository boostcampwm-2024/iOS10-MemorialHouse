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
    private var nextPageViewController: ReadPageViewController?
    private var previousPageViewController: ReadPageViewController?
    
    // MARK: - Initialize
    init(viewModel: BookViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setup()
        configureNavigationBar()
        configureConstraints()
        input.send(.loadBookTitle)
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
                Task { await self?.configureFirstPageViewController(firstPage: page) }
            case .moveToEdit(let bookID, let bookTitle):
                Task { await self?.presentEditBookView(bookID: bookID, bookTitle: bookTitle) }
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
            title: "닫기".localized(),
            normal: normalAttributes,
            selected: selectedAttributes
        ) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        // 오른쪽 책 속지 수정 버튼
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "수정".localized(),
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
    private func configureFirstPageViewController(firstPage: Page) async {
        guard let startViewController = await makeNewPageViewController(page: firstPage) else { return }
        let viewControllers = [startViewController]
        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        prepareAdjacentViewControllers()
    }
    
    private func prepareAdjacentViewControllers() {
        Task {
            if let nextPage = viewModel.nextPage {
                nextPageViewController = await makeNewPageViewController(page: nextPage)
            }
            if let previousPage = viewModel.previousPage {
                previousPageViewController = await makeNewPageViewController(page: previousPage)
            }
        }
    }
    
    private func makeNewPageViewController(page: Page) async -> ReadPageViewController? {
        guard let readPageViewModelFactory = try? await DIContainer.shared.resolve(ReadPageViewModelFactory.self) else {
            return nil
        }
        let readPageViewModel = readPageViewModelFactory.make(bookID: viewModel.identifier, page: page)
        
        return ReadPageViewController(viewModel: readPageViewModel)
    }
    
    // MARK: - PresentEditBookView
    private func presentEditBookView(bookID: UUID, bookTitle: String) async {
        do {
            let editBookViewModelFactory = try await DIContainer.shared.resolve(EditBookViewModelFactory.self)
            let editBookViewModel = editBookViewModelFactory.make(bookID: bookID, bookTitle: bookTitle)
            let editBookViewController = EditBookViewController(viewModel: editBookViewModel, mode: .modify)
            navigationController?.pushViewController(editBookViewController, animated: true)
        } catch {
            MHLogger.error(error.localizedDescription + #function)
        }
    }
}

// MARK: - UIPageViewControllerDelegate
extension BookViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed {
            prepareAdjacentViewControllers()
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension BookViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard viewModel.previousPage != nil else { return nil }
        input.send(.loadPreviousPage)
        
        let previousViewController = previousPageViewController
        previousPageViewController = nil
        return previousViewController
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard viewModel.nextPage != nil else { return nil }
        input.send(.loadNextPage)
        
        let nextViewController = nextPageViewController
        nextPageViewController = nil
        return nextViewController
    }
}
