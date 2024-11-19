import UIKit

final class EditPhotoViewController: UIViewController {
    // MARK: - Properties
    private let clearView = UIView.dimmedView(opacity: 0)
    private let dimmedView1 = UIView.dimmedView(opacity: 0.5)
    private let dimmedView2 = UIView.dimmedView(opacity: 0.5)
    private let topView = UIView.dimmedView(opacity: 1, color: .black)
    private let bottomView = UIView.dimmedView(opacity: 1, color: .black)
    private let dividedLine1 = UIView.dividedLine()
    private let dividedLine2 = UIView.dividedLine()
    private let photoScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.clipsToBounds = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        return scrollView
    }()
    private let photoImageView: UIImageView = {
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
    private var captionTextFieldBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Deinitialize
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureAddSubView()
        configureConstraints()
        configureButtonAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavagationBar()
    }
    
    // MARK: - Setup
    private func setup() {
        view.backgroundColor = .black
        photoScrollView.delegate = self
        hideKeyboardWhenTappedView()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Configure Navigation
    private func configureNavagationBar() {
        // Navigation Bar
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .black
        navigationBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.ownglyphBerry(size: 17),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.compactAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.title = "사진 편집"
        
        // Left Bar BarButton
        let closeAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        let leftBarButton = UIBarButtonItem(title: "닫기", primaryAction: closeAction)
        leftBarButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.ownglyphBerry(size: 17),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ], for: .normal)
        leftBarButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.ownglyphBerry(size: 17)
        ], for: .selected)
        navigationItem.leftBarButtonItem = leftBarButton

        // Right Bar Button
        let completeAction = UIAction { _ in
            // TODO: 다음 화면으로 전환 및 cropImage 호출
        }
        let rightBarButton = UIBarButtonItem(title: "완료", primaryAction: completeAction)
        rightBarButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.ownglyphBerry(size: 17),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ], for: .normal)
        rightBarButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.ownglyphBerry(size: 17)
        ], for: .selected)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    // MARK: - Add SubView & Constraints
    private func configureAddSubView() {
        editButtonStackView.addArrangedSubview(rotateButton)
        editButtonStackView.addArrangedSubview(drawButton)
        photoScrollView.addSubview(photoImageView)
        
        [photoScrollView,
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
            trailing: view.trailingAnchor,
            height: 30
        )
        captionTextFieldBottomConstraint = captionTextField.bottomAnchor.constraint(
            equalTo: dividedLine2.topAnchor,
            constant: -11
        )
        captionTextFieldBottomConstraint?.isActive = true
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
        clearView.setAnchor(
            top: topView.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: dividedLine1.topAnchor,
            trailing: view.trailingAnchor
        )
        dimmedView2.setAnchor(
            top: photoScrollView.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: dividedLine1.topAnchor,
            trailing: view.trailingAnchor
        )
        dimmedView1.setAnchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            bottom: photoScrollView.topAnchor,
            trailing: view.trailingAnchor
        )
        photoScrollView.setWidthAndHeight(width: view.frame.width, height: view.frame.width * 0.75)
        photoScrollView.setCenter(view: clearView)
        photoImageView.setWidthAndHeight(width: photoScrollView.widthAnchor, height: photoScrollView.heightAnchor)
        photoImageView.setAnchor(
            top: photoScrollView.topAnchor,
            leading: photoScrollView.leadingAnchor,
            bottom: photoScrollView.bottomAnchor,
            trailing: photoScrollView.trailingAnchor
        )
    }
    
    // MARK: - Add Button Action
    private func configureButtonAction() {
        let rotateButtonAction = UIAction { [weak self] _ in
            guard let self else { return }
            let image = self.photoImageView.image
            self.photoImageView.image = image?.rotate(radians: .pi / 2)
        }
        let drawButtonAction = UIAction { _ in
            // TODO: - Draw Action
        }
        rotateButton.addAction(rotateButtonAction, for: .touchUpInside)
        drawButton.addAction(drawButtonAction, for: .touchUpInside)
    }
    
    // MARK: - Keyboard Appear & Hide
    @objc private func keyboardWillAppear(_ notification: Notification) {
        guard let keyboardInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey],
              let keyboardSize = keyboardInfo as? CGRect else { return }
        let bottomConstant = editButtonStackView.frame.height + view.safeAreaInsets.bottom
        captionTextFieldBottomConstraint?.constant = bottomConstant - keyboardSize.height
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide() {
        captionTextFieldBottomConstraint?.constant = -11
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Crop Image
    private func cropImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: photoScrollView.bounds)
        return renderer.image { _ in
            self.photoScrollView.drawHierarchy(in: self.photoScrollView.bounds, afterScreenUpdates: true)
        }
    }
    
    // MARK: - Set Photo from Custom Album
    func setPhoto(image: UIImage?, date: Date?) {
        photoImageView.image = image
    }
}

// MARK: - UIScrollViewDelegate
extension EditPhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        reorderImage(scrollView, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        reorderImage(scrollView, animated: false)
    }
    
    private func reorderImage(_ scrollView: UIScrollView, animated: Bool) {
        let photoSize = originalImageSize()
        let scrollViewSize = scrollView.frame.size
        var contentOffset = scrollView.contentOffset
        
        if photoSize.width < scrollViewSize.width {
            contentOffset.x = (scrollView.contentSize.width - scrollViewSize.width) / 2
            scrollView.setContentOffset(contentOffset, animated: animated)
        }

        if photoSize.height < scrollViewSize.height {
            contentOffset.y = (scrollView.contentSize.height - scrollViewSize.height) / 2
            scrollView.setContentOffset(contentOffset, animated: animated)
        }
    }
    
    private func originalImageSize() -> CGSize {
        guard let image = photoImageView.image else { return .zero}
        let ratio = image.size.height / image.size.width
        if ratio <= 0.75 {
            return CGSize(width: photoImageView.frame.width, height: photoImageView.frame.width * ratio)
        } else {
            return CGSize(width: photoImageView.frame.height / ratio, height: photoImageView.frame.height)
        }
    }
}
