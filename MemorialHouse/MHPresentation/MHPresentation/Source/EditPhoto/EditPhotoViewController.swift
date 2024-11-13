import UIKit

public final class EditPhotoViewController: UIViewController {
    // MARK: - Properties
    private let clearView = UIView.dimmedView(opacity: 0)
    private let dimmedView1 = UIView.dimmedView(opacity: 0.5)
    private let dimmedView2 = UIView.dimmedView(opacity: 0.5)
    private let topView = UIView.dimmedView(opacity: 1, color: .black)
    private let bottomView = UIView.dimmedView(opacity: 1, color: .black)
    private let dividedLine1 = UIView.dividedLine()
    private let dividedLine2 = UIView.dividedLine()
    private let photoView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
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
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        
        return stackView
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
        configureGesture()
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
        let closeAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        let leftBarButton = UIBarButtonItem(title: "닫기", primaryAction: closeAction)
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
        [rotateButton,
         drawButton].forEach {
            editButtonStackView.addArrangedSubview($0)
        }
        
        [photoView,
         dimmedView1,
         clearView,
         dimmedView2,
         topView,
         bottomView,
         dividedLine1,
         captionTextField,
         dividedLine2,
         editButtonStackView].forEach {
            view.addSubview($0)
        }
    }
    
    private func configureConstraints() {
        editButtonStackView.setAnchor(
            leading: view.leadingAnchor, constantLeading: 50,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor, constantTrailing: 50,
            height: 80
        )
        dividedLine2.setHorizontal(view: view)
        dividedLine2.setBottom(anchor: editButtonStackView.topAnchor, constant: 11)
        captionTextField.setAnchor(
            leading: view.leadingAnchor, constantLeading: 13,
            bottom: dividedLine2.topAnchor, constantBottom: 11,
            trailing: view.trailingAnchor,
            height: 30
        )
        dividedLine1.setHorizontal(view: view)
        dividedLine1.setBottom(anchor: captionTextField.topAnchor, constant: 11)
        topView.setAnchor(
            top: view.topAnchor,
            leading: view.leadingAnchor,
            bottom: dimmedView1.topAnchor,
            trailing: view.trailingAnchor
        )
        bottomView.setAnchor(
            top: dividedLine1.topAnchor,
            leading: view.leadingAnchor,
            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor
        )
        photoView.setAnchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            bottom: dividedLine1.topAnchor,
            trailing: view.trailingAnchor
        )
        clearView.setAnchor(width: view.frame.width, height: view.frame.width * 0.75)
        clearView.setCenter(view: photoView)
        dimmedView2.setAnchor(
            top: clearView.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: dividedLine1.topAnchor,
            trailing: view.trailingAnchor
        )
        dimmedView1.setAnchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            bottom: clearView.topAnchor,
            trailing: view.trailingAnchor
        )
    }
    
    private func configureButtonAction() {
        let rotateButtonAction = UIAction { [weak self] _ in
            guard let self else { return }
            let image = self.photoView.image
            self.photoView.image = image?.rotate(radians: .pi / 2)
        }
        let drawButtonAction = UIAction { _ in
            // TODO: - Draw Action
        }
        rotateButton.addAction(rotateButtonAction, for: .touchUpInside)
        drawButton.addAction(drawButtonAction, for: .touchUpInside)
    }
    
    private func configureGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureAction(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        panGesture.maximumNumberOfTouches = 2
        photoView.addGestureRecognizer(pinchGesture)
        photoView.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Gesture Action
    @objc private func pinchGestureAction(_ sender: UIPinchGestureRecognizer) {
        photoView.transform = photoView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    @objc private func panGestureAction(_ sender: UIPanGestureRecognizer) {
        let transition = sender.translation(in: photoView)
        let changedX = photoView.center.x + transition.x
        let changedY = photoView.center.y + transition.y
        photoView.center = CGPoint(x: changedX, y: changedY)
        
        sender.setTranslation(CGPoint.zero, in: photoView)
    }
    
    // MARK: - Set Photo from Custom Album
    func setPhoto(image: UIImage?) {
        photoView.image = image
    }
}

// MARK: - UITextFieldDelegate
extension EditPhotoViewController: UITextFieldDelegate {
    // TODO: - TextField의 텍스트 처리
}
