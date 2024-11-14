import UIKit

final class EditBookViewController: UIViewController {
    // MARK: - Property
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .ownglyphBerry(size: 15)
        textView.textColor = .mhTitle
        textView.tintColor = .mhTitle
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 32, bottom: 20, right: 32)
        textView.layer.borderWidth = 3
        textView.layer.borderColor = UIColor.mhTitle.cgColor
        
        return textView
    }()
    private let addImageButton: UIButton = {
        let button = UIButton()
        button.setImage(.imageButton, for: .normal)
        button.backgroundColor = .clear
        
        return button
    }()
    private let addVideoButton: UIButton = {
        let button = UIButton()
        button.setImage(.videoButton, for: .normal)
        button.backgroundColor = .clear
        
        return button
    }()
    private let addTextButton: UIButton = {
        let button = UIButton()
        button.setImage(.textButton, for: .normal)
        button.backgroundColor = .clear
        
        return button
    }()
    private let addAudioButton: UIButton = {
        let button = UIButton()
        button.setImage(.audioButton, for: .normal)
        button.backgroundColor = .clear
        
        return button
    }()
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureAddSubView()
    }
    
    // MARK: - Setup & Configuration
    private func setup() {
        view.backgroundColor = .baseBackground
        hideKeyboardWhenTappedView()
    }
    private func configureAddSubView() {
        // textView
        view.addSubview(textView)
        
        // buttonStackView
        buttonStackView.addArrangedSubview(addImageButton)
        buttonStackView.addArrangedSubview(addVideoButton)
        buttonStackView.addArrangedSubview(addTextButton)
        buttonStackView.addArrangedSubview(addAudioButton)
        view.addSubview(buttonStackView)
        
    }
    private func configureConstraints() {
        // textView
        textView.setAnchor(
            top: view.safeAreaLayoutGuide.topAnchor, constantTop: 20,
            leading: view.leadingAnchor, constantLeading: 20,
            bottom: buttonStackView.topAnchor, constantBottom: 20,
            trailing: view.trailingAnchor, constantTrailing: 20
        )
        // buttonStackView
        buttonStackView.setAnchor(
            leading: textView.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor, constantBottom: 20,
            trailing: view.trailingAnchor, constantTrailing: 20,
            height: 50
        )
    }
}
