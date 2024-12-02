import UIKit
import MHCore
import Combine

final class CreateBookViewController: UIViewController {
    // MARK: - Constant
    static let maxTitleLength = 10
    // MARK: - Property
    private let bookView: MHBookCover = MHBookCover()
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
        [UIColor.mhPink, .mhGreen, .mhBlue, .mhOrange, .mhBeige, .clear]
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
        var attributedTitle = AttributedString(stringLiteral: "없음")
        attributedTitle.font = UIFont.ownglyphBerry(size: 25)
        
        button.setAttributedTitle(NSAttributedString(attributedTitle), for: .normal)
        button.setTitleColor(.mhTitle, for: .normal)
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
    @Published
    private var viewModel: CreateBookViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(viewModel: CreateBookViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        viewModel = CreateBookViewModel()
        
        super.init(coder: coder)
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureConstraints()
        configureNavigationBar()
        configureViewModelBinding()
        configureAction()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let currentColorButton = bookColorButtons[viewModel.currentColorNumber]
        self.addInnerShadow(to: currentColorButton)
    }
    
    // MARK: - TouchEvent
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
        super.touchesBegan(touches, with: event)
    }
    
    // MARK: - Helper
    private func setup() {
        view.backgroundColor = .baseBackground
        bookTitleTextField.delegate = self
        bookColorButtons.last?.isUserInteractionEnabled = false // 마지막 버튼은 크기 조절을 위한 것
    }
    private func configureConstraints() {
        // 책 미리보기
        let bookPreviewViewBackground = bookView.embededInDefaultBackground(
            with: UIEdgeInsets(top: 70, left: 100, bottom: 70, right: 100)
        )
        view.addSubview(bookPreviewViewBackground)
        bookPreviewViewBackground.setAnchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.safeAreaLayoutGuide.leadingAnchor, constantLeading: 16,
            trailing: view.safeAreaLayoutGuide.trailingAnchor, constantTrailing: 16,
            height: 344
        )
        
        // 책 제목
        let bookTitleTextFieldBackground = bookTitleTextField
            .titledContentView(leftTitle: "책 제목 | ")
            .embededInDefaultBackground()
        view.addSubview(bookTitleTextFieldBackground)
        bookTitleTextFieldBackground.setAnchor(
            top: bookPreviewViewBackground.bottomAnchor, constantTop: 12,
            leading: bookPreviewViewBackground.leadingAnchor,
            trailing: bookPreviewViewBackground.trailingAnchor,
            height: 63
        )
        
        // 책 색상 버튼
        let bookColorSelectionBackground = configuredColorButtons()
        view.addSubview(bookColorSelectionBackground)
        bookColorSelectionBackground.setAnchor(
            top: bookTitleTextFieldBackground.bottomAnchor, constantTop: 8,
            leading: bookTitleTextFieldBackground.leadingAnchor,
            trailing: bookTitleTextFieldBackground.trailingAnchor,
            height: 113
        )
        // 카테고리
        let categorySelectionButtonBackground = categorySelectionButton
            .titledContentView(leftTitle: "카테고리 | ")
            .embededInDefaultBackground()
        view.addSubview(categorySelectionButtonBackground)
        categorySelectionButtonBackground.setAnchor(
            top: bookColorSelectionBackground.bottomAnchor, constantTop: 8,
            leading: bookColorSelectionBackground.leadingAnchor,
            trailing: bookColorSelectionBackground.trailingAnchor,
            height: 63
        )
        
        // 사진선택
        let imageSelectionButtonBackground = imageSelectionButton
            .embededInDefaultBackground()
        view.addSubview(imageSelectionButtonBackground)
        imageSelectionButtonBackground.setAnchor(
            top: categorySelectionButtonBackground.bottomAnchor, constantTop: 8,
            leading: categorySelectionButtonBackground.leadingAnchor,
            trailing: categorySelectionButtonBackground.trailingAnchor,
            height: 63
        )
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.ownglyphBerry(size: 17),
            .foregroundColor: UIColor.mhTitle
        ]
        title = "책 표지 만들기"
        
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
        
        // 오른쪽 책 속지 만들기 버튼
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "책 속지 만들기",
            normal: normalAttributes,
            selected: selectedAttributes
        ) { [weak self] in
            // TODO: - 추후 DIContainer resolve 실패 처리 필요
            // TODO: - bookID에 bookCoverID 넣어주기 필요
            guard let editBookViewModelFactory = try? DIContainer.shared.resolve(EditBookViewModelFactory.self) else { return }
            let viewModel = editBookViewModelFactory.make(bookID: .init())
            self?.navigationController?.pushViewController(
                EditBookViewController(viewModel: viewModel),
                animated: true
            )
        }
    }
    
    private func configureAction() {
        // 색깔 버튼
        bookColorButtons.enumerated().forEach { idx, button in
            let action = UIAction { [weak self] _ in
                guard let self else { return }
                self.viewModel.previousColorNumber = self.viewModel.currentColorNumber
                self.viewModel.currentColorNumber = idx
            }
            button.addAction(action, for: .touchUpInside)
        }
        
        // TitleTextField 변경
        let titleAction = UIAction { [weak self] _ in
            guard let self else { return }
            if self.bookTitleTextField.text?.count ?? 0 > Self.maxTitleLength {
                self.bookTitleTextField.text = String(self.bookTitleTextField.text?.prefix(Self.maxTitleLength) ?? "")
            }
            
            self.viewModel.bookTitle = self.bookTitleTextField.text ?? ""
        }
        bookTitleTextField.addAction(titleAction, for: .editingChanged)
        
        // TODO: - 카테고리 선택 뷰모델에 반영
        
        // 사진선택 버튼
        let pictureSelectingAction = UIAction { [weak self] _ in
            let albumViewModel = CustomAlbumViewModel()
            let customAlbumViewController = CustomAlbumViewController(viewModel: albumViewModel, mediaType: .image)
            self?.navigationController?.pushViewController(customAlbumViewController, animated: true)
        }
        imageSelectionButton.addAction(pictureSelectingAction, for: .touchUpInside)
        
        // TODO: - 사진 선택 뷰모델?에 반영
        
    }
    private func configureViewModelBinding() {
        $viewModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewModel in
                guard let self else { return }
                self.bookView.configure(
                    title: viewModel.bookTitle,
                    bookCoverImage: viewModel.currentColor.image,
                    // TODO: -  이미지 선택시 변경
                    targetImage: .rotate,
                    houseName: viewModel.houseName
                )
            }
            .store(in: &cancellables)
        $viewModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewModel in
                guard viewModel.previousColorNumber != -1 else { return }
                guard let self else { return }
                let previousButton = self.bookColorButtons[viewModel.previousColorNumber]
                self.removeSubLayersAndaddOuterShadow(to: previousButton)
                let currentColorButton = self.bookColorButtons[viewModel.currentColorNumber]
                self.addInnerShadow(to: currentColorButton)
            }
            .store(in: &cancellables)
    }
    private func configuredColorButtons() -> UIView { // 린트 경고 때문에 분리
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
    private func removeSubLayersAndaddOuterShadow(to view: UIView) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.colorButtonInnerShadow.removeFromSuperlayer()
            view.layer.shadowOpacity = 0.25
        }
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
}

extension CreateBookViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
