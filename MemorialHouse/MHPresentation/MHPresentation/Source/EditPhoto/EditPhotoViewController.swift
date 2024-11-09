import UIKit

public final class EditPhotoViewController: UIViewController {
    // MARK: - Constants
    private static let captionTextSize: CGFloat = 17
    private static let stackViewSpacing: CGFloat = 83
    private let dividedLinePaddingConstraints: CGFloat = 11
    private let stackViewBottomConstraints: CGFloat = 16
    
    // MARK: - Properties
    private let cropButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .crop
        let button = UIButton()
        button.configuration = configuration
        
        return button
    }()
    private let rotateButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .rotate
        let button = UIButton()
        button.configuration = configuration
        
        return button
    }()
    private let drawButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .draw
        let button = UIButton()
        button.configuration = configuration
        
        return button
    }()
    private let editButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = stackViewSpacing
        stackView.alignment = .center
        
        return stackView
    }()
    private let captionTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "캡션을 입력해주세요.",
            attributes: [.foregroundColor: UIColor.captionPlaceHolder]
        )
        textField.font = UIFont.ownglyphBerry(size: captionTextSize)
        textField.textColor = .white
        
        return textField
    }()
    private let dividedLine1 = UIView.dividedLine()
    private let dividedLine2 = UIView.dividedLine()
    
    // MARK: - View Did Load
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureConstraints()
        configureButtonAction()
    }
    
    // MARK: - Setup & Configure
    private func setup() {
        view.backgroundColor = .black
        [cropButton,
         rotateButton,
         drawButton].forEach {
            editButtonStackView.addArrangedSubview($0)
        }
        captionTextField.delegate = self
        self.hideKeyboardWhenTappedView()
    }
    
    private func configureConstraints() {
        [editButtonStackView,
         dividedLine1,
         captionTextField,
         dividedLine2].forEach {
            view.addSubview($0)
        }
        
        editButtonStackView.setCenterX(view: view)
        editButtonStackView.setBottom(
            anchor: view.safeAreaLayoutGuide.bottomAnchor,
            constant: stackViewBottomConstraints
        )
        dividedLine1.setHorizontal(view: view)
        dividedLine1.setBottom(
            anchor: editButtonStackView.topAnchor,
            constant: dividedLinePaddingConstraints
        )
        captionTextField.setHorizontal(view: view)
        captionTextField.setBottom(
            anchor: dividedLine1.topAnchor,
            constant: dividedLinePaddingConstraints
        )
        dividedLine2.setHorizontal(view: view)
        dividedLine2.setBottom(
            anchor: captionTextField.topAnchor,
            constant: dividedLinePaddingConstraints
        )
    }
    
    private func configureButtonAction() {
        let cropButtonAction = UIAction { _ in
            // TODO: - Crop Action
        }
        let rotateButtonAction = UIAction { _ in
            // TODO: - Rotate Action
        }
        let drawButtonAction = UIAction { _ in
            // TODO: - Draw Action
        }
        cropButton.addAction(cropButtonAction, for: .touchUpInside)
        rotateButton.addAction(rotateButtonAction, for: .touchUpInside)
        drawButton.addAction(drawButtonAction, for: .touchUpInside)
    }
}

extension EditPhotoViewController: UITextFieldDelegate {
    // TODO: - TextField의 텍스트 처리
}
