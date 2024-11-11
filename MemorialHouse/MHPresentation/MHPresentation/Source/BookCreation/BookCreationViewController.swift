import UIKit

final class BookCreationViewController: UIViewController {
    // MARK: - Property
    private let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .pinkBook)
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    private let bookTitleTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.ownglyphBerry(size: 25)
        textField.textColor = .black
        
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
        button.setTitleColor(.title, for: .normal)
        button.contentHorizontalAlignment = .left
        
        return button
    }()
    private let imageSelectionButton: UIButton = {
        let button = UIButton()
        var attributedTitle = AttributedString(stringLiteral: "사진 선택")
        attributedTitle.font = UIFont.ownglyphBerry(size: 25)
        
        button.setAttributedTitle(NSAttributedString(attributedTitle), for: .normal)
        button.setTitleColor(.title, for: .normal)
        
        return button
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureConstraints()
    }
    
    // MARK: - TouchEvent
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
        super.touchesBegan(touches, with: event)
    }
    
    // MARK: - Helper
    private func configureConstraints() {
        // 책 미리보기
        let bookPreviewViewBackground = bookImageView.embededInDefaultBackground(
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
}