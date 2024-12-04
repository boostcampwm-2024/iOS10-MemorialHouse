import UIKit

final class MHRegisterView: UIView {
    // MARK: UI Components
    let registerTextField: UITextField = {
        let registerFont = UIFont.ownglyphBerry(size: 20)
        
        let textField = UITextField()
        textField.font = registerFont
        
        var attributedText = AttributedString(stringLiteral: "ex) 영현")
        attributedText.font = registerFont
        textField.textAlignment = .right
        textField.attributedPlaceholder = NSAttributedString(attributedText)
        
        return textField
    }()
    private let registerLabel = UILabel(style: .header2)
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        
        setup()
        configureAddSubview()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
        configureAddSubview()
        configureLayout()
    }
    
    func configure(textFieldAction: @escaping (String?) -> Void) {
        registerTextField.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            textFieldAction(self.registerTextField.text)
        }, for: .editingChanged)
    }
    
    // MARK: - Setup & Configuration
    private func setup() {
        backgroundColor = .baseBackground
        registerLabel.text = "기록소"
    }
    
    private func configureAddSubview() {
        addSubview(registerTextField)
        addSubview(registerLabel)
    }
        
    private func configureLayout() {
        registerTextField.setAnchor(
            top: topAnchor,
            leading: leadingAnchor,
            bottom: bottomAnchor,
            trailing: registerLabel.leadingAnchor, constantTrailing: 8
        )
        registerLabel.setAnchor(
            trailing: trailingAnchor, constantTrailing: 4
        )
        registerLabel.setCenterY(view: self)
    }
}
