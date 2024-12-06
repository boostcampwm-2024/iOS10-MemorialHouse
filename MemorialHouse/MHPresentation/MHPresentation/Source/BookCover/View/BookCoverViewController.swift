import UIKit
import MHCore
import Combine

final class BookCoverViewController: UIViewController {
    enum Mode {
        case create
        case modify
    }
    
    // MARK: - UI Components
    private let bookCoverView: MHBookCover = MHBookCover()
    private let bookTitleTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.ownglyphBerry(size: 25)
        textField.textColor = .black
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        
        var attributedText = AttributedString(stringLiteral: "책 제목을 입력하세요")
        attributedText.font = UIFont.ownglyphBerry(size: 25)
        textField.attributedPlaceholder = NSAttributedString(attributedText)
        
        return textField
    }()
    private let bookColorButtons: [UIButton] = zip(
        ["분 홍", "초 록", "파 랑", "주 황", "베이지", ""],
        [.mhPink, .mhGreen, .mhBlue, .mhOrange, .mhBeige, .clear]
    ).map { (title: String, color: UIColor) in
        let button = UIButton(frame: CGRect(origin: .zero, size: .init(width: 66, height: 30)))
        var attributedTitle = AttributedString(stringLiteral: title)
        attributedTitle.font = UIFont.ownglyphBerry(size: 20)
        
        button.setAttributedTitle(NSAttributedString(attributedTitle), for: .normal)
        button.backgroundColor = color
        
        button.layer.cornerRadius = 15
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        return button
    }
    private let categorySelectionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemGray3, for: .normal) // TODO: - 우측에 > 이미지 추가
        button.setAttributedTitle(
            NSAttributedString(string: "카테고리를 선택해주세요", attributes: [.font: UIFont.ownglyphBerry(size: 25)]),
            for: .normal
        )
        button.contentHorizontalAlignment = .left
        
        return button
    }()
    private let imageSelectionButton: UIButton = {
        let button = UIButton()
        var attributedTitle = AttributedString(stringLiteral: "사진 선택")
        attributedTitle.font = UIFont.ownglyphBerry(size: 25)
        
        button.setAttributedTitle(NSAttributedString(attributedTitle), for: .normal)
        button.setTitleColor(.mhTitle, for: .normal)
        
        return button
    }()
    private let colorButtonInnerShadow: CAShapeLayer = {
        let shadowLayer = CAShapeLayer()
        shadowLayer.cornerRadius = 15
        shadowLayer.fillColor = nil
        shadowLayer.masksToBounds = true
        
        // 그림자 경로 생성
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOpacity = 0.35
        shadowLayer.shadowOffset = CGSize(width: 0, height: 4)
        shadowLayer.shadowRadius = 3
        
        return shadowLayer
    }()
    private lazy var bookPreviewViewBackground = bookCoverView.embededInDefaultBackground(
        with: UIEdgeInsets(top: 50, left: 80, bottom: 50, right: 80)
    )
    private lazy var bookTitleTextFieldBackground = bookTitleTextField
        .titledContentView(leftTitle: "책 제목 | ")
        .embededInDefaultBackground()
    private lazy var bookColorSelectionBackground = configuredColorButtons()
    private lazy var categorySelectionButtonBackground = categorySelectionButton
        .titledContentView(leftTitle: "카테고리 | ")
        .embededInDefaultBackground()
    private lazy var imageSelectionButtonBackground = imageSelectionButton
        .embededInDefaultBackground()
    
    // MARK: - Property
    private let mode: Mode
    private let createViewModel: CreateBookCoverViewModel?
    private let modifyViewModel: ModifyBookCoverViewModel?
    private let createInput = PassthroughSubject<CreateBookCoverViewModel.Input, Never>()
    private let modifyInput = PassthroughSubject<ModifyBookCoverViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(
        createViewModel: CreateBookCoverViewModel? = nil,
        modifyViewModel: ModifyBookCoverViewModel? = nil,
        mode: Mode
    ) {
        self.createViewModel = createViewModel
        self.modifyViewModel = modifyViewModel
        self.mode = mode
        
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        createViewModel = nil
        modifyViewModel = nil
        mode = .create
        
        super.init(coder: coder)
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setup()
        configureNavigationBar()
        configureAddSubviews()
        configureConstraints()
        configureAction()
        createInput.send(.setBookCover)
        modifyInput.send(.loadBookCover)
    }
    
    // MARK: - TouchEvent
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
        super.touchesBegan(touches, with: event)
    }
    
    // MARK: - Binding
    private func bind() {
        switch mode {
        case .create:
            createViewModelBind()
        case .modify:
            modifyViewModelBind()
        }
    }
    
    private func createViewModelBind() {
        let output = createViewModel?.transform(input: createInput.eraseToAnyPublisher())
        
        output?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .memorialHouseName(let name):
                    self?.bookCoverView.configure(houseName: name)
                case .bookTitle(let title):
                    self?.bookCoverView.configure(title: title)
                case .bookColorIndex(let previousIndex, let nowIndex, let bookColor):
                    self?.bookColorButtonTapped(
                        previousIndex: previousIndex,
                        nowIndex: nowIndex,
                        bookCoverImage: bookColor.image
                    )
                case .bookImage(let imageData):
                    guard let imageData else { return }
                    self?.bookCoverView.configure(targetImage: UIImage(data: imageData))
                case .bookCategory(let category):
                    self?.setCategorySelectionButton(category: category)
                case .moveToNext(let bookID):
                    self?.presentEditBookView(bookID: bookID)
                case .moveToHome:
                    self?.navigationController?.popViewController(animated: true)
                case .settingFailure:
                    self?.showFailureAlert()
                }
            }.store(in: &cancellables)
    }
    
    private func modifyViewModelBind() {
        let output = modifyViewModel?.transform(input: modifyInput.eraseToAnyPublisher())
        
        output?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .memorialHouseName(let name):
                    self?.bookCoverView.configure(houseName: name)
                case .setModifyView(let title, let category):
                    self?.setBookCoverView(title: title, category: category)
                case .bookTitle(let title):
                    self?.bookCoverView.configure(title: title)
                case .bookColorIndex(let previousIndex, let nowIndex, let bookColor):
                    self?.bookColorButtonTapped(
                        previousIndex: previousIndex,
                        nowIndex: nowIndex,
                        bookCoverImage: bookColor.image
                    )
                case .bookImage(let imageData):
                    guard let imageData else { return }
                    self?.bookCoverView.configure(targetImage: UIImage(data: imageData))
                case .bookCategory(let category):
                    self?.setCategorySelectionButton(category: category)
                case .moveToHome:
                    self?.navigationController?.popViewController(animated: true)
                case .settingFailure:
                    self?.showFailureAlert()
                }
            }.store(in: &cancellables)
    }
    
    private func showFailureAlert() {
        let alert = UIAlertController(
            title: "책 표지 생성 실패",
            message: "책 제목을 입력해주세요",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        
        present(alert, animated: true)
    }
    
    // MARK: - Present EditBookViewController
    private func presentEditBookView(bookID: UUID) {
        do {
            guard let bookTitle = bookTitleTextField.text else { return }
            let editBookViewModelFactory = try DIContainer.shared.resolve(EditBookViewModelFactory.self)
            let editBookViewModel = editBookViewModelFactory.make(bookID: bookID, bookTitle: bookTitle)
            let editBookViewController = EditBookViewController(viewModel: editBookViewModel)
            navigationController?.pushViewController(editBookViewController, animated: true)
        } catch {
            MHLogger.error(error.localizedDescription + #function)
        }
    }
}

// MARK: - Setup & Configure
extension BookCoverViewController {
    private func setup() {
        view.backgroundColor = .baseBackground
        bookTitleTextField.delegate = self
        bookColorButtons.last?.isUserInteractionEnabled = false // 마지막 버튼은 크기 조절을 위한 것
    }
    
    private func setBookCoverView(title: String?, category: String?) {
        bookTitleTextField.text = title
        setCategorySelectionButton(category: category)
    }
    
    private func configureNavigationBar() {
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ownglyphBerry(size: 17),
            .foregroundColor: UIColor.mhTitle
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ownglyphBerry(size: 17),
            .foregroundColor: UIColor.mhTitle
        ]
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.titleTextAttributes = normalAttributes
        
        switch mode {
        case .create:
            createNavigationBar(normalAttributes: normalAttributes, selectedAttributes: selectedAttributes)
        case .modify:
            modifyNavigationBar(normalAttributes: normalAttributes, selectedAttributes: selectedAttributes)
        }
    }
    
    private func createNavigationBar(
        normalAttributes: [NSAttributedString.Key: Any],
        selectedAttributes: [NSAttributedString.Key: Any]
    ) {
        title = "책 표지 만들기"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "닫기",
            normal: normalAttributes,
            selected: selectedAttributes
        ) { [weak self] in
            self?.createInput.send(.deleteBookCover)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "책 속지 만들기",
            normal: normalAttributes,
            selected: selectedAttributes
        ) { [weak self] in
            self?.createInput.send(.saveBookCover)
        }
    }
    
    private func modifyNavigationBar(
        normalAttributes: [NSAttributedString.Key: Any],
        selectedAttributes: [NSAttributedString.Key: Any]
    ) {
        title = "책 표지 수정"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "닫기",
            normal: normalAttributes,
            selected: selectedAttributes
        ) { [weak self] in
            // TODO: - Alert 띄우기
            self?.modifyInput.send(.cancelModifyBookCover)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "완료",
            normal: normalAttributes,
            selected: selectedAttributes
        ) { [weak self] in
            self?.modifyInput.send(.saveBookCover)
        }
    }
    
    private func configureAddSubviews() {
        view.addSubview(bookPreviewViewBackground)
        view.addSubview(bookTitleTextFieldBackground)
        view.addSubview(bookColorSelectionBackground)
        view.addSubview(categorySelectionButtonBackground)
        view.addSubview(imageSelectionButtonBackground)
    }
    
    private func configureConstraints() {
        bookPreviewViewBackground.setAnchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.safeAreaLayoutGuide.leadingAnchor, constantLeading: 16,
            trailing: view.safeAreaLayoutGuide.trailingAnchor, constantTrailing: 16,
            height: 344
        )
        bookTitleTextFieldBackground.setAnchor(
            top: bookPreviewViewBackground.bottomAnchor, constantTop: 12,
            leading: bookPreviewViewBackground.leadingAnchor,
            trailing: bookPreviewViewBackground.trailingAnchor,
            height: 63
        )
        bookColorSelectionBackground.setAnchor(
            top: bookTitleTextFieldBackground.bottomAnchor, constantTop: 8,
            leading: bookTitleTextFieldBackground.leadingAnchor,
            trailing: bookTitleTextFieldBackground.trailingAnchor,
            height: 113
        )
        categorySelectionButtonBackground.setAnchor(
            top: bookColorSelectionBackground.bottomAnchor, constantTop: 8,
            leading: bookColorSelectionBackground.leadingAnchor,
            trailing: bookColorSelectionBackground.trailingAnchor,
            height: 63
        )
        imageSelectionButtonBackground.setAnchor(
            top: categorySelectionButtonBackground.bottomAnchor, constantTop: 8,
            leading: categorySelectionButtonBackground.leadingAnchor,
            trailing: categorySelectionButtonBackground.trailingAnchor,
            height: 63
        )
    }
    
    private func configureAction() {
        bookColorButtons.enumerated().forEach { index, button in
            let colorButtonAction = UIAction { [weak self] _ in
                self?.createInput.send(.changedBookColor(colorIndex: index))
                self?.modifyInput.send(.changedBookColor(colorIndex: index))
            }
            button.addAction(colorButtonAction, for: .touchUpInside)
        }
        
        let titleAction = UIAction { [weak self] _ in
            guard let self else { return }
            let maxTitleLength = 10
            if self.bookTitleTextField.text?.count ?? 0 > maxTitleLength {
                self.bookTitleTextField.text = String(self.bookTitleTextField.text?.prefix(maxTitleLength) ?? "")
            }
            self.createInput.send(.changedBookTitle(title: bookTitleTextField.text))
            self.modifyInput.send(.changedBookTitle(title: bookTitleTextField.text))
        }
        bookTitleTextField.addAction(titleAction, for: .editingChanged)
        
        let selectPhotoAction = UIAction { [weak self] _ in
            let albumViewModel = CustomAlbumViewModel()
            let customAlbumViewController = CustomAlbumViewController(
                viewModel: albumViewModel,
                mediaType: .image,
                mode: .bookCover,
                videoSelectCompletionHandler: nil
            ) { imageData, _, _ in
                self?.createInput.send(.changedBookImage(bookImage: imageData))
                self?.modifyInput.send(.changedBookImage(bookImage: imageData))
            }
            let navigationViewController = UINavigationController(rootViewController: customAlbumViewController)
            navigationViewController.modalPresentationStyle = .fullScreen
            self?.present(navigationViewController, animated: true)
        }
        imageSelectionButton.addAction(selectPhotoAction, for: .touchUpInside)
        
        let selectCategoryAction = UIAction { [weak self] _ in
            self?.presentCategorySelectionView()
        }
        categorySelectionButton.addAction(selectCategoryAction, for: .touchUpInside)
    }
    
    private func configuredColorButtons() -> UIView {
        let firstLineColorButtonStackView  = UIStackView()
        firstLineColorButtonStackView.axis = .horizontal
        firstLineColorButtonStackView.distribution = .fillEqually
        firstLineColorButtonStackView.alignment = .center
        firstLineColorButtonStackView.spacing = 13
        (0..<3).forEach { firstLineColorButtonStackView.addArrangedSubview(bookColorButtons[$0]) }
        
        let secondLineColorButtonStackView = UIStackView()
        secondLineColorButtonStackView.axis = .horizontal
        secondLineColorButtonStackView.distribution = .fillEqually
        secondLineColorButtonStackView.alignment = .center
        secondLineColorButtonStackView.spacing = 13
        (3..<6).forEach { secondLineColorButtonStackView.addArrangedSubview(bookColorButtons[$0]) }
        
        let colorButtonStackView = UIStackView(
            arrangedSubviews: [firstLineColorButtonStackView, secondLineColorButtonStackView]
        )
        colorButtonStackView.axis = .vertical
        colorButtonStackView.distribution = .fillEqually
        colorButtonStackView.alignment = .fill
        
        let bookColorSelectionBackground = colorButtonStackView
            .titledContentView(leftTitle: "책 색상 | ")
            .embededInDefaultBackground()
        
        return bookColorSelectionBackground
    }
}

// MARK: - Color Button (Lint 에러로 분리)
extension BookCoverViewController {
    private func bookColorButtonTapped(previousIndex: Int?, nowIndex: Int, bookCoverImage: UIImage) {
        if let previousIndex {
            let previousColorButton = bookColorButtons[previousIndex]
            removeSubLayersAndaddOuterShadow(to: previousColorButton)
        }
        guard nowIndex >= 0 && nowIndex < bookColorButtons.count else { return }
        let currentColorButton = bookColorButtons[nowIndex]
        addInnerShadow(to: currentColorButton)
        
        bookCoverView.configure(bookCoverImage: bookCoverImage)
    }
    
    private func addInnerShadow(to view: UIView) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }
            let bounds = view.bounds
            let path = UIBezierPath(rect: bounds)
            let cutoutPath = UIBezierPath(rect: bounds.insetBy(dx: 0, dy: -4)).reversing()
            path.append(cutoutPath)

            self.colorButtonInnerShadow.shadowPath = path.cgPath
            self.colorButtonInnerShadow.frame = bounds
            view.layer.shadowOpacity = 0
            view.layer.addSublayer(self.colorButtonInnerShadow)
        }
    }
    
    private func removeSubLayersAndaddOuterShadow(to view: UIView) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.colorButtonInnerShadow.removeFromSuperlayer()
            view.layer.shadowOpacity = 0.25
        }
    }
}

// MARK: - UITextFieldDelegate
extension BookCoverViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Category Bottom Sheet
extension BookCoverViewController: BookCategoryViewControllerDelegate {
    private func presentCategorySelectionView() {
        do {
            let categoryViewModelFactory = try DIContainer.shared.resolve(BookCategoryViewModelFactory.self)
            let categoryViewModel = categoryViewModelFactory.makeForCreateBook()
            let categoryViewController = BookCategoryViewController(viewModel: categoryViewModel)
            let navigationController = UINavigationController(rootViewController: categoryViewController)
            categoryViewController.delegate = self
            
            if let sheet = navigationController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
            }
            
            self.present(navigationController, animated: true)
        } catch {
            MHLogger.error(error.localizedDescription + #function)
        }
    }
    
    private func setCategorySelectionButton(category: String?) {
        if let category {
            categorySelectionButton.setTitleColor(.mhTitle, for: .normal)
            categorySelectionButton.setAttributedTitle(
                NSAttributedString(string: category, attributes: [.font: UIFont.ownglyphBerry(size: 25)]),
                for: .normal
            )
        } else {
            categorySelectionButton.setTitleColor(.systemGray3, for: .normal)
            categorySelectionButton.setAttributedTitle(
                NSAttributedString(string: "카테고리를 선택해주세요", attributes: [.font: UIFont.ownglyphBerry(size: 25)]),
                for: .normal
            )
        }
    }
    
    func categoryViewController(
        _ categoryViewController: BookCategoryViewController,
        didSelectCategory category: String
    ) {
        createInput.send(.changedBookCategory(category: category))
        modifyInput.send(.changedBookCategory(category: category))
    }
}
