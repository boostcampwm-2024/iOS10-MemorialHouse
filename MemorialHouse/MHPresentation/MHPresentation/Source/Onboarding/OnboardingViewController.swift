import UIKit
import MHCore

public final class OnboardingViewController: UIViewController {
    // MARK: - UI Components
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        var attributedTitle = AttributedString(stringLiteral: "건너뛰기")
        attributedTitle.font = UIFont.ownglyphBerry(size: 20)
        
        button.setAttributedTitle(NSAttributedString(attributedTitle), for: .normal)
        button.setTitleColor(.gray, for: .normal)
        
        return button
    }()
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        
        return pageControl
    }()
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        var attributedTitle = AttributedString(stringLiteral: "다음")
        attributedTitle.font = UIFont.ownglyphBerry(size: 30)
        
        button.setAttributedTitle(NSAttributedString(attributedTitle), for: .normal)
        button.setTitleColor(.mhTitle, for: .normal)
        button.backgroundColor = .accent
        button.layer.cornerRadius = 20
        
        return button
    }()
    
    // MARK: - Property
    private let pages: [UIViewController] = [
        OnboardingPageViewController(image: .onboardingOne),
        OnboardingPageViewController(image: .onboardingTwo),
        OnboardingPageViewController(image: .onboardingThree),
        OnboardingPageViewController(image: .onboardingFour)
    ]
    private var currentPageIndex: Int = 0 {
        didSet {
            pageControl.currentPage = currentPageIndex
            updateNextButtonTitle()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureAddSubview()
        configureConstraint()
        configureAddActions()
    }
    
    // MARK: - Setup & Configuration
    private func setup() {
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.setViewControllers(
            [pages[0]],
            direction: .forward,
            animated: true,
            completion: nil
        )
        pageControl.numberOfPages = pages.count
    }
    
    private func configureAddSubview() {
        view.addSubview(skipButton)
        view.addSubview(pageViewController.view)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
    }
    
    private func configureConstraint() {
        skipButton.setTop(anchor: view.safeAreaLayoutGuide.topAnchor)
        skipButton.setTrailing(anchor: view.trailingAnchor, constant: 20)
        
        pageViewController.view.setTop(anchor: skipButton.bottomAnchor, constant: 4)
        pageViewController.view.setLeading(anchor: view.leadingAnchor)
        pageViewController.view.setTrailing(anchor: view.trailingAnchor)
        pageViewController.view.setBottom(anchor: pageControl.topAnchor, constant: 4)
        
        pageControl.setCenterX(view: view)
        pageControl.setBottom(anchor: nextButton.topAnchor, constant: 16)
        
        nextButton.setLeading(anchor: view.leadingAnchor, constant: 32)
        nextButton.setTrailing(anchor: view.trailingAnchor, constant: 32)
        nextButton.setBottom(anchor: view.safeAreaLayoutGuide.bottomAnchor, constant: 16)
        nextButton.setHeight(56)
    }
    
    private func configureAddActions() {
        skipButton.addAction(UIAction { [weak self] _ in
            self?.moveToRegister()
        }, for: .touchUpInside)
        
        nextButton.addAction(UIAction { [weak self] _ in
            self?.handleNextButtonTap()
        }, for: .touchUpInside)
    }

    private func handleNextButtonTap() {
        if currentPageIndex == pages.count - 1 {
            moveToRegister()
        } else {
            currentPageIndex += 1
            pageViewController.setViewControllers(
                [pages[currentPageIndex]],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }
    }
    
    private func updateNextButtonTitle() {
        let title = currentPageIndex == pages.count - 1 ? "완료" : "다음"
        if nextButton.currentAttributedTitle?.string != title {
            var attributedTitle = AttributedString(stringLiteral: title)
            attributedTitle.font = UIFont.ownglyphBerry(size: 30)
            attributedTitle.foregroundColor = .black
            
            nextButton.setAttributedTitle(NSAttributedString(attributedTitle), for: .normal)
        }
    }
    
    private func moveToRegister() {
        do {
            let viewModelFactory = try DIContainer.shared.resolve(RegisterViewModelFactory.self)
            let viewModel = viewModelFactory.make()
            let registerViewController = RegisterViewController(viewModel: viewModel)
            navigationController?.pushViewController(registerViewController, animated: true)
        } catch {
            MHLogger.error("\(#function) moveToRegister 실패")
            showErrorAlert(with: "알 수 없는 오류가 발생했습니다.")
        }
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed, let visibleViewController = pageViewController.viewControllers?.first,
              let index = pages.firstIndex(of: visibleViewController) else { return }
        
        currentPageIndex = index
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }
    
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}
