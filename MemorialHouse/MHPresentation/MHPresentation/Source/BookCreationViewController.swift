import UIKit

public final class BookCreationViewController: UIViewController {
    // MARK: - Property
    private let bookPreviewViewBackground = UIView()
    private let bookPreview: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        view.layer.cornerRadius = 17
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.mhBorder.cgColor
        view.clipsToBounds = true
        
        return view
    }()
    private let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .pinkBook)
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    private let bookTitleTextFieldBackground = UIView()
    private let bookTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "책 제목을 입력하세요"
        
        let leftView = UILabel(style: .default)
        
        leftView.text = "책 제목 | "
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        textField.layer.cornerRadius = 17
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.mhBorder.cgColor
        textField.clipsToBounds = true
        
        return textField
    }()
    private let bookColorSelectionBackground = UIView()
    private let bookColorSelectionTitleLabel: UIView = {
        let view = UILabel(style: .default)
        view.text = "책 색상 | "
        view.textAlignment = .left
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return view
    }()
    private let bookColorSelectionView: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 17
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.mhBorder.cgColor
        view.clipsToBounds = true
        
        return view
    }()
    private let firstLineColorButtonStackView: UIStackView = {
        let firstLine = UIStackView()
        firstLine.axis = .horizontal
        firstLine.distribution = .fillEqually
        firstLine.alignment = .center
        firstLine.spacing = 13
        
        return firstLine
    }()
    private let secondLineColorButtonStackView: UIStackView = {
        let secondLine = UIStackView()
        secondLine.axis = .horizontal
        secondLine.distribution = .fillEqually
        secondLine.alignment = .center
        secondLine.spacing = 13
        
        return secondLine
    }()
    private let colorButtonStackView: UIStackView = {
        let entireStackView = UIStackView()
        entireStackView.axis = .vertical
        entireStackView.distribution = .fillEqually
        entireStackView.alignment = .fill
        return entireStackView
    }()
    private let bookColorButtons: [UIButton] = zip(
        ["분홍", "초록", "파랑", "주황", "베이지", nil],
        [UIColor.mhPink, .mhGreen, .mhBlue, .mhOrange, .mhBeige, .clear]
    ).map { title, color in
        let button = UIButton(frame: CGRect(origin: .zero, size: .init(width: 66, height: 30)))
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 15
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        return button
    }
    private let categorySelectionButtonBackground = UIView()
    private let categorySelectionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("카테고리 선택 | 없음", for: .normal)
        button.setTitleColor(.title, for: .normal)
        button.contentHorizontalAlignment = .left
        
        button.backgroundColor = .clear
        
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.mhBorder.cgColor
        button.clipsToBounds = true
        
        return button
    }()
    private let imageSelectionButtonBackground = UIView()
    private let imageSelectionButton: UIButton = {
        let button = UIButton()
        button.setTitle("사진 선택", for: .normal)
        button.setTitleColor(.title, for: .normal)
        button.backgroundColor = .clear
        
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.mhBorder.cgColor
        button.clipsToBounds = true
        
        return button
    }()
    
    // MARK: - LifeCycle
    public override func loadView() {
        self.view = UIScrollView()
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHirachy()
        configureLayout()
    }
    
    // MARK: - Helper
    private func configureHirachy() {
        // 리사이즈 마스크 사용 안함
        bookPreviewViewBackground.translatesAutoresizingMaskIntoConstraints = false
        bookPreview.translatesAutoresizingMaskIntoConstraints = false
        bookImageView.translatesAutoresizingMaskIntoConstraints = false
        bookTitleTextFieldBackground.translatesAutoresizingMaskIntoConstraints = false
        bookTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        bookColorSelectionBackground.translatesAutoresizingMaskIntoConstraints = false
        bookColorSelectionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        bookColorSelectionView.translatesAutoresizingMaskIntoConstraints = false
        firstLineColorButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        secondLineColorButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        colorButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        bookColorButtons.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        categorySelectionButtonBackground.translatesAutoresizingMaskIntoConstraints = false
        categorySelectionButton.translatesAutoresizingMaskIntoConstraints = false
        imageSelectionButtonBackground.translatesAutoresizingMaskIntoConstraints = false
        imageSelectionButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 책 미리보기
        configureBackgroundView(bookPreviewViewBackground, withContent: bookPreview)
        
        // 책 이미지
        bookPreview.addSubview(bookImageView)
        
        // 책 제목
        configureBackgroundView(bookTitleTextFieldBackground, withContent: bookTitleTextField)
        
        // 책 색상 타이틀
        configureBackgroundView(bookColorSelectionBackground, withContent: bookColorSelectionView)
        bookColorSelectionView.addSubview(bookColorSelectionTitleLabel)
        
        // 책 색상 버튼
        bookColorSelectionView.addSubview(colorButtonStackView)
        (0..<3).forEach { firstLineColorButtonStackView.addArrangedSubview(bookColorButtons[$0]) }
        (3..<6).forEach { secondLineColorButtonStackView.addArrangedSubview(bookColorButtons[$0]) }
        colorButtonStackView.addArrangedSubview(firstLineColorButtonStackView)
        colorButtonStackView.addArrangedSubview(secondLineColorButtonStackView)

        // 카테고리
        configureBackgroundView(categorySelectionButtonBackground, withContent: categorySelectionButton)
        
        // 사진선택
        configureBackgroundView(imageSelectionButtonBackground, withContent: imageSelectionButton)
    }
    private func configureLayout() {
        // 책 프리뷰 배경
        NSLayoutConstraint.activate([
            bookPreviewViewBackground.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            bookPreviewViewBackground.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            bookPreviewViewBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bookPreviewViewBackground.heightAnchor.constraint(equalToConstant: 344)
        ])
        // 책 이미지
        NSLayoutConstraint.activate([
            bookImageView.leadingAnchor.constraint(equalTo: bookPreview.leadingAnchor, constant: 100),
            bookImageView.trailingAnchor.constraint(equalTo: bookPreview.trailingAnchor, constant: -100),
            bookImageView.topAnchor.constraint(equalTo: bookPreview.topAnchor, constant: 70),
            bookImageView.bottomAnchor.constraint(equalTo: bookPreview.bottomAnchor, constant: -70)
        ])
        // 책 제목 입력
        NSLayoutConstraint.activate([
            bookTitleTextFieldBackground.leadingAnchor.constraint(equalTo: bookPreviewViewBackground.leadingAnchor),
            bookTitleTextFieldBackground.trailingAnchor.constraint(equalTo: bookPreviewViewBackground.trailingAnchor),
            bookTitleTextFieldBackground.topAnchor.constraint(equalTo: bookPreviewViewBackground.bottomAnchor, constant: 12),
            bookTitleTextFieldBackground.heightAnchor.constraint(equalToConstant: 63)
        ])
        // 책 색 선택 왼쪽 타이틀
        NSLayoutConstraint.activate([
            bookColorSelectionTitleLabel.topAnchor.constraint(equalTo: bookColorSelectionView.topAnchor),
            bookColorSelectionTitleLabel.leadingAnchor.constraint(equalTo: bookColorSelectionView.leadingAnchor, constant: 10),
            bookColorSelectionTitleLabel.bottomAnchor.constraint(equalTo: bookColorSelectionView.bottomAnchor)
        ])
        // 책 버튼들
        NSLayoutConstraint.activate([
            colorButtonStackView.leadingAnchor.constraint(equalTo: bookColorSelectionTitleLabel.trailingAnchor, constant: 20),
            colorButtonStackView.trailingAnchor.constraint(equalTo: bookColorSelectionView.trailingAnchor, constant: -18),
            colorButtonStackView.topAnchor.constraint(equalTo: bookColorSelectionView.topAnchor, constant: 5),
            colorButtonStackView.bottomAnchor.constraint(equalTo: bookColorSelectionView.bottomAnchor, constant: -5)
        ])
        // 책 색 선택 배경
        NSLayoutConstraint.activate([
            bookColorSelectionBackground.leadingAnchor.constraint(equalTo: bookTitleTextFieldBackground.leadingAnchor),
            bookColorSelectionBackground.trailingAnchor.constraint(equalTo: bookTitleTextFieldBackground.trailingAnchor),
            bookColorSelectionBackground.topAnchor.constraint(equalTo: bookTitleTextFieldBackground.bottomAnchor, constant: 8),
            bookColorSelectionBackground.heightAnchor.constraint(equalToConstant: 113)
        ])
        // 카테고리 선택 배경
        NSLayoutConstraint.activate([
            categorySelectionButtonBackground.leadingAnchor.constraint(equalTo: bookColorSelectionBackground.leadingAnchor),
            categorySelectionButtonBackground.trailingAnchor.constraint(equalTo: bookColorSelectionBackground.trailingAnchor),
            categorySelectionButtonBackground.topAnchor.constraint(equalTo: bookColorSelectionBackground.bottomAnchor, constant: 8),
            categorySelectionButtonBackground.heightAnchor.constraint(equalToConstant: 63)
        ])
        // 이미지 선택 배경
        NSLayoutConstraint.activate([
            imageSelectionButtonBackground.leadingAnchor.constraint(equalTo: categorySelectionButtonBackground.leadingAnchor),
            imageSelectionButtonBackground.trailingAnchor.constraint(equalTo: categorySelectionButtonBackground.trailingAnchor),
            imageSelectionButtonBackground.topAnchor.constraint(equalTo: categorySelectionButtonBackground.bottomAnchor, constant: 8),
            imageSelectionButtonBackground.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -27),
            imageSelectionButtonBackground.heightAnchor.constraint(equalToConstant: 63)
        ])
    }
    private func configureBackgroundView(_ backGroundView: UIView, withContent view: UIView) {
        backGroundView.backgroundColor = .mhSection
        backGroundView.layer.cornerRadius = 20
        backGroundView.clipsToBounds = true
        backGroundView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 6),
            view.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -6),
            view.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 7),
            view.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -7)
        ])
        
        self.view.addSubview(backGroundView)
    }
}
