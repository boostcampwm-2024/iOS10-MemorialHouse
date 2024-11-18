import UIKit
import MHFoundation
import Combine

final class MHRegisterView: UIView {
    static let buttonSubject = PassthroughSubject<String, Never>()
    
    // MARK: - Property
    private let coverImageView: UIImageView = {
        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage.pinkBook
        
        return backgroundImageView
    }()
    private static let registerButtonFontSize: CGFloat = 12
    private static let registerTextFieldFontSize: CGFloat = 24
    private let registerTextLabel: UILabel = {
        let registerFont = UIFont.ownglyphBerry(size: registerTextFieldFontSize)
        
        let textLabel = UILabel()
        textLabel.text = """
                        추억을 간직할
                        기록소 이름을 작성해주세요
                        """
        textLabel.textAlignment = .center
        textLabel.font = registerFont
        textLabel.numberOfLines = 2
        
        return textLabel
    }()
    let registerTextField: UITextField = {
        let registerFont = UIFont.ownglyphBerry(size: registerButtonFontSize)
        
        let textField = UITextField()
        textField.font = registerFont
        textField.borderStyle = .none
        
        var attributedText = AttributedString(stringLiteral: "기록소")
        attributedText.font = registerFont
        textField.attributedPlaceholder = NSAttributedString(attributedText)
        
        return textField
    }()
    let registerButton: UIButton = {
        let registerButton = UIButton(type: .custom)
        
        var attributedString = AttributedString(stringLiteral: "다음")
        attributedString.font = UIFont.ownglyphBerry(size: registerButtonFontSize)
        attributedString.strokeColor = UIColor.mhTitle
        
        registerButton.setAttributedTitle(NSAttributedString(attributedString), for: .normal)
        
        registerButton.backgroundColor = .mhSection
        registerButton.layer.borderColor = UIColor.mhBorder.cgColor
        registerButton.layer.borderWidth = 1
        registerButton.layer.cornerRadius = registerButtonFontSize
        
        return registerButton
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        configureAddSubviewAndConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: CGRect(x: 0, y: 0, width: 352, height: 234))
        setup()
        configureAddSubviewAndConstraints()
    }
    
    // MARK: - Setup
    private func setup() {
        addTouchEventToRegisterButton(registerButton)
        addEditingChangedEventToRegisterTextField(registerTextField)
        coverImageView.isUserInteractionEnabled = true
    }
    
    // MARK: - Configure
    private func configureAddSubviewAndConstraints() {
        coverImageView.setWidthAndHeight(width: self.frame.width, height: self.frame.height)
        self.addSubview(coverImageView)
        
        coverImageView.addSubview(registerTextLabel)
        registerTextLabel.setAnchor(
            leading: self.leadingAnchor,
            constantLeading: 80,
            trailing: self.trailingAnchor,
            constantTrailing: 40,
            
            height: 96
        )
        
        let registerTextFieldBackground = registerTextField
                                            .embededInDefaultBackground(with:
                                            UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 5))
        coverImageView.addSubview(registerTextFieldBackground)
        registerTextFieldBackground.setAnchor(
            top: registerTextLabel.bottomAnchor,
            leading: self.leadingAnchor,
            constantLeading: 80,
            trailing: self.trailingAnchor,
            constantTrailing: 40,
            height: 44
        )
        
        let registerButtonBackground = UIView()
        registerButtonBackground.backgroundColor = .mhSection
        registerButtonBackground.layer.cornerRadius = MHRegisterView.registerButtonFontSize + 1
        registerButtonBackground.clipsToBounds = true
        registerButtonBackground.addSubview(registerButton)
        registerButton.setAnchor(
            top: registerButtonBackground.topAnchor, constantTop: 3,
            leading: registerButtonBackground.leadingAnchor, constantLeading: 4,
            bottom: registerButtonBackground.bottomAnchor, constantBottom: 3,
            trailing: registerButtonBackground.trailingAnchor, constantTrailing: 4
        )
        
        coverImageView.addSubview(registerButtonBackground)
        registerButtonBackground.setAnchor(
            top: registerTextFieldBackground.bottomAnchor,
            constantTop: 10,
            leading: self.leadingAnchor,
            constantLeading: 260,
            
            width: 60,
            height: 36
        )
    }
    
    private func addTouchEventToRegisterButton(_ button: UIButton) {
        let uiAction = UIAction { [weak self] _ in
            MHRegisterView.buttonSubject.send(self?.registerTextField.text ?? "")
        }
        registerButton.addAction(uiAction, for: .touchUpInside)
    }
    
    private func addEditingChangedEventToRegisterTextField(_ textfield: UITextField) {
        let uiAction = UIAction { _ in
            guard let inputText = textfield.text else { return }
        }
        registerTextField.addAction(uiAction, for: .editingChanged)
    }
}
