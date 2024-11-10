import UIKit

public final class RegisterViewController: UIViewController {
    private static let registerButtonFontSize: CGFloat = 12
    private static let registerTextFieldFontSize: CGFloat = 24
    private let registerTextField: UITextField = {
        let registerFont = UIFont.ownglyphBerry(size: registerButtonFontSize)
        
        let textField = UITextField()
        textField.font = registerFont
        textField.borderStyle = .roundedRect
        
        var attributedText = AttributedString(stringLiteral: "기록소")
        attributedText.font = registerFont
        textField.attributedPlaceholder = NSAttributedString(attributedText)
        
        return textField
    }()
    private let registerButton: UIButton = {
        let registerButton = UIButton()
        
        var attributedString = AttributedString(stringLiteral: "다음")
        attributedString.font = UIFont.ownglyphBerry(size: registerButtonFontSize)
        
        registerButton.setAttributedTitle(NSAttributedString(attributedString), for: .normal)
        
        registerButton.titleLabel?.textColor = #colorLiteral(red: 0.1843137255, green: 0.1843137255, blue: 0.1843137255, alpha: 1)
        registerButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        registerButton.layer.borderColor = #colorLiteral(red: 0.7019607843, green: 0.1490196078, blue: 0.1176470588, alpha: 1)
        registerButton.layer.borderWidth = 1
        registerButton.layer.cornerRadius = registerButtonFontSize
        
        return registerButton
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureAddSubView()
        configureConstraints()
    }
    
    private func setup() {
        view.backgroundColor = .baseBackground
        addTouchEventToRegisterButton(registerButton)
    }
    
    private func configureAddSubView() {
        view.addSubview(registerTextField)
        view.addSubview(registerButton)
    }
    
    private func configureConstraints() {
        registerTextField.setHeight(RegisterViewController.registerTextFieldFontSize)
        registerTextField.setWidth(RegisterViewController.registerTextFieldFontSize * 8)
        registerTextField.setCenter(view: view)
        
        registerButton.setHeight(RegisterViewController.registerButtonFontSize * 2)
        registerButton.setWidth(RegisterViewController.registerButtonFontSize * 4)
        registerButton.setTop(anchor: registerTextField.bottomAnchor, constant: 6)
        registerButton.setLeading(anchor: registerTextField.trailingAnchor, constant: -6)
    }
    
    private func addTouchEventToRegisterButton(_ button: UIButton) {
        let uiAction = UIAction { [weak self] _ in
            // TODO: - 저장소 중복 체크
            
            guard let houseName = self?.registerTextField.text, !houseName.isEmpty else {
                self?.showAlert()
                return
            }
            
            let userDefaults = UserDefaults.standard
            
            userDefaults.set(houseName, forKey: Constant.houseName)
            
            self?.navigationController?.pushViewController(HomeViewController(), animated: false)
            self?.navigationController?.viewControllers.removeFirst()    // inactive back to register view
        }
        
        button.addAction(uiAction, for: .touchUpInside)
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "기록소 이름을 입력해주세요.", message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "확인", style: .default)
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
