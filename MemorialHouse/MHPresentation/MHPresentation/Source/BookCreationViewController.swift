import UIKit

public final class BookCreationViewController: UIViewController {
    // MARK: - Property
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
    private let bookTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "책 제목을 입력하세요"
        
        let leftView = UILabel(style: .default)
        
        leftView.text = " 책 제목 | "
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        textField.layer.cornerRadius = 17
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.mhBorder.cgColor
        textField.clipsToBounds = true
        
        return textField
    }()
    private let bookColorSelectionView: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 17
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.mhBorder.cgColor
        view.clipsToBounds = true
        
        return view
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
    private let categorySelectionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(" 카테고리 선택 | 없음", for: .normal)
        button.setTitleColor(.title, for: .normal)
        button.contentHorizontalAlignment = .left
        
        button.backgroundColor = .clear
        
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.mhBorder.cgColor
        button.clipsToBounds = true
        
        return button
    }()
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
    }
    
    // MARK: - Helper
    private func configureHirachy() {
        // 리사이즈 마스크 사용 안함
        bookPreview.translatesAutoresizingMaskIntoConstraints = false
        bookImageView.translatesAutoresizingMaskIntoConstraints = false
        bookTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        bookColorSelectionView.translatesAutoresizingMaskIntoConstraints = false
        bookColorButtons.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        categorySelectionButton.translatesAutoresizingMaskIntoConstraints = false
        imageSelectionButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 책 미리보기
        let bookPreviewViewBackground = addBackgroundView(to: bookPreview)
        view.addSubview(bookPreviewViewBackground)
        NSLayoutConstraint.activate([
            bookPreviewViewBackground.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            bookPreviewViewBackground.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            bookPreviewViewBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bookPreviewViewBackground.heightAnchor.constraint(equalToConstant: 344)
        ])
        
        // 책 이미지
        bookPreview.addSubview(bookImageView)
        NSLayoutConstraint.activate([
            bookImageView.leadingAnchor.constraint(equalTo: bookPreview.leadingAnchor, constant: 100),
            bookImageView.trailingAnchor.constraint(equalTo: bookPreview.trailingAnchor, constant: -100),
            bookImageView.topAnchor.constraint(equalTo: bookPreview.topAnchor, constant: 70),
            bookImageView.bottomAnchor.constraint(equalTo: bookPreview.bottomAnchor, constant: -70)
        ])
        
        // 책 제목
        let bookTitleTextFieldBackground = addBackgroundView(to: bookTitleTextField)
        view.addSubview(bookTitleTextFieldBackground)
        NSLayoutConstraint.activate([
            bookTitleTextFieldBackground.leadingAnchor.constraint(equalTo: bookPreviewViewBackground.leadingAnchor),
            bookTitleTextFieldBackground.trailingAnchor.constraint(equalTo: bookPreviewViewBackground.trailingAnchor),
            bookTitleTextFieldBackground.topAnchor.constraint(equalTo: bookPreviewViewBackground.bottomAnchor, constant: 12),
            bookTitleTextFieldBackground.heightAnchor.constraint(equalToConstant: 63)
        ])
        
        // 책 색상 타이틀
        let bookColorSelectionBackground = addBackgroundView(to: bookColorSelectionView)
        let bookColorSelectionTitleLabel = UILabel(style: .default)
        bookColorSelectionTitleLabel.text = "책 색상 | "
        bookColorSelectionTitleLabel.textAlignment = .left
        bookColorSelectionTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        bookColorSelectionView.addSubview(bookColorSelectionTitleLabel)
        NSLayoutConstraint.activate([
            bookColorSelectionTitleLabel.topAnchor.constraint(equalTo: bookColorSelectionView.topAnchor),
            bookColorSelectionTitleLabel.leadingAnchor.constraint(equalTo: bookColorSelectionView.leadingAnchor, constant: 10),
            bookColorSelectionTitleLabel.bottomAnchor.constraint(equalTo: bookColorSelectionView.bottomAnchor)
        ])
        
        // 책 버튼
        let firstLineColorButtons = UIStackView()
        (0..<3).forEach { firstLineColorButtons.addArrangedSubview(bookColorButtons[$0]) }
        firstLineColorButtons.axis = .horizontal
        firstLineColorButtons.distribution = .fillEqually
        firstLineColorButtons.alignment = .center
        firstLineColorButtons.spacing = 13
        let secondLineColorButtons = UIStackView()
        (3..<6).forEach { secondLineColorButtons.addArrangedSubview(bookColorButtons[$0]) }
        secondLineColorButtons.axis = .horizontal
        secondLineColorButtons.distribution = .fillEqually
        secondLineColorButtons.alignment = .center
        secondLineColorButtons.spacing = 13
        let colorButtonsStackView = UIStackView(arrangedSubviews: [firstLineColorButtons, secondLineColorButtons])
        colorButtonsStackView.axis = .vertical
        colorButtonsStackView.distribution = .fillEqually
        colorButtonsStackView.alignment = .fill
        
        bookColorSelectionBackground.addSubview(colorButtonsStackView)
        colorButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorButtonsStackView.leadingAnchor.constraint(equalTo: bookColorSelectionTitleLabel.trailingAnchor, constant: 20),
            colorButtonsStackView.trailingAnchor.constraint(equalTo: bookColorSelectionView.trailingAnchor, constant: -18),
            colorButtonsStackView.topAnchor.constraint(equalTo: bookColorSelectionView.topAnchor, constant: 5),
            colorButtonsStackView.bottomAnchor.constraint(equalTo: bookColorSelectionView.bottomAnchor, constant: -5)
        ])
        
        view.addSubview(bookColorSelectionBackground)
        NSLayoutConstraint.activate([
            bookColorSelectionBackground.leadingAnchor.constraint(equalTo: bookTitleTextFieldBackground.leadingAnchor),
            bookColorSelectionBackground.trailingAnchor.constraint(equalTo: bookTitleTextFieldBackground.trailingAnchor),
            bookColorSelectionBackground.topAnchor.constraint(equalTo: bookTitleTextFieldBackground.bottomAnchor, constant: 8),
            bookColorSelectionBackground.heightAnchor.constraint(equalToConstant: 113)
        ])
        
        // 카테고리
        let categorySelectionButtonBackground = addBackgroundView(to: categorySelectionButton)
        view.addSubview(categorySelectionButtonBackground)
        NSLayoutConstraint.activate([
            categorySelectionButtonBackground.leadingAnchor.constraint(equalTo: bookColorSelectionBackground.leadingAnchor),
            categorySelectionButtonBackground.trailingAnchor.constraint(equalTo: bookColorSelectionBackground.trailingAnchor),
            categorySelectionButtonBackground.topAnchor.constraint(equalTo: bookColorSelectionBackground.bottomAnchor, constant: 8),
            categorySelectionButtonBackground.heightAnchor.constraint(equalToConstant: 63)
        ])
        
        // 사진선택
        let imageSelectionButtonBackground = addBackgroundView(to: imageSelectionButton)
        view.addSubview(imageSelectionButtonBackground)
        NSLayoutConstraint.activate([
            imageSelectionButtonBackground.leadingAnchor.constraint(equalTo: categorySelectionButtonBackground.leadingAnchor),
            imageSelectionButtonBackground.trailingAnchor.constraint(equalTo: categorySelectionButtonBackground.trailingAnchor),
            imageSelectionButtonBackground.topAnchor.constraint(equalTo: categorySelectionButtonBackground.bottomAnchor, constant: 8),
            imageSelectionButtonBackground.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -27),
            imageSelectionButtonBackground.heightAnchor.constraint(equalToConstant: 63)
        ])
        
    }
    private func addBackgroundView(to view: UIView) -> UIView {
        let backGroundView = UIView()
        backGroundView.translatesAutoresizingMaskIntoConstraints = false
        backGroundView.backgroundColor = .mhSection
        backGroundView.layer.cornerRadius = 20
        backGroundView.clipsToBounds = true
        backGroundView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 6),
            view.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -6),
            view.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 7),
            view.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -7)
        ])
        
        return backGroundView
    }
}
