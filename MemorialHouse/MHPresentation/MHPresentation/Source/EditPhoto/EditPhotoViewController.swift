import UIKit

public final class EditPhotoViewController: UIViewController {
    // MARK: - Properties
    private let photoView = UIImageView()
    private let clearView = UIView.dimmedView(opacity: 0)
    private let dimmedView1 = UIView.dimmedView(opacity: 0.5)
    private let dimmedView2 = UIView.dimmedView(opacity: 0.5)
    private let dividedLine1 = UIView.dividedLine()
    private let dividedLine2 = UIView.dividedLine()
    private let captionTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "캡션을 입력해주세요.",
            attributes: [.foregroundColor: UIColor.captionPlaceHolder]
        )
        textField.font = UIFont.ownglyphBerry(size: 17)
        textField.textColor = .white
        
        return textField
    }()
    private let editButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 83
        stackView.alignment = .center
        
        return stackView
    }()
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
    
    // MARK: - View Did Load
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureNavagationBar()
        configureAddSubView()
        configureConstraints()
        configureButtonAction()
    }
    
    // MARK: - Setup & Configure
    private func setup() {
        view.backgroundColor = .black
        captionTextField.delegate = self
        self.hideKeyboardWhenTappedView()
    }
    
    private func configureNavagationBar() {
        navigationItem.title = "사진 편집"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.ownglyphBerry(size: 17),
            NSAttributedString.Key.foregroundColor: UIColor.white]
        let leftBarButton = UIBarButtonItem(title: "닫기")
        leftBarButton.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.ownglyphBerry(size: 17),
             NSAttributedString.Key.foregroundColor: UIColor.white],
            for: .normal
        )
        navigationItem.leftBarButtonItem = leftBarButton
        let rightBarButton = UIBarButtonItem(title: "완료")
        rightBarButton.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.ownglyphBerry(size: 17),
             NSAttributedString.Key.foregroundColor: UIColor.white],
            for: .normal
        )
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func configureAddSubView() {
        [cropButton,
         rotateButton,
         drawButton].forEach {
            editButtonStackView.addArrangedSubview($0)
        }
        
        [dimmedView1,
         clearView,
         dimmedView2].forEach {
            photoView.addSubview($0)
        }
        
        [photoView,
         dividedLine1,
         captionTextField,
         dividedLine2,
         editButtonStackView].forEach {
            view.addSubview($0)
        }
    }
    
    private func configureConstraints() {
        editButtonStackView.setCenterX(view: view)
        editButtonStackView.setBottom(
            anchor: view.safeAreaLayoutGuide.bottomAnchor,
            constant: 16
        )
        dividedLine1.setHorizontal(view: view)
        dividedLine1.setBottom(
            anchor: editButtonStackView.topAnchor,
            constant: 11
        )
        captionTextField.setAnchor(
            leading: view.leadingAnchor, constantLeading: 13,
            bottom: dividedLine1.topAnchor, constantBottom: 11,
            trailing: view.trailingAnchor
        )
        dividedLine2.setHorizontal(view: view)
        dividedLine2.setBottom(
            anchor: captionTextField.topAnchor,
            constant: 11
        )
        photoView.setAnchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            bottom: dividedLine2.topAnchor,
            trailing: view.trailingAnchor
        )
        clearView.setAnchor(width: view.frame.width, height: view.frame.width * 0.75)
        clearView.setCenter(view: photoView)
        dimmedView1.setAnchor(
            top: photoView.topAnchor,
            leading: view.leadingAnchor,
            bottom: clearView.topAnchor,
            trailing: view.trailingAnchor
        )
        dimmedView2.setAnchor(
            top: clearView.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: dividedLine2.topAnchor,
            trailing: view.trailingAnchor
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
