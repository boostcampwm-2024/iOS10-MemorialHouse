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
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
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
        photoScrollView.delegate = self
        captionTextField.delegate = self
        hideKeyboardWhenTappedView()
    }
    
    private func configureNavagationBar() {
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
        let closeAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        let leftBarButton = UIBarButtonItem(title: "닫기", primaryAction: closeAction)
        leftBarButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.ownglyphBerry(size: 17),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ], for: .normal)
        navigationItem.leftBarButtonItem = leftBarButton
        let rightBarButton = UIBarButtonItem(title: "완료")
        rightBarButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.ownglyphBerry(size: 17),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ], for: .normal)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
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
    
    // MARK: - Set Photo from Custom Album
    func setPhoto(image: UIImage?) {
        photoImageView.image = image
    }
}

// MARK: - UITextFieldDelegate
extension EditPhotoViewController: UITextFieldDelegate {
    // TODO: - TextField의 텍스트 처리
}

extension EditPhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let photoSize = originalImageSize()
        let scrollViewSize = scrollView.frame.size
        var contentOffset = scrollView.contentOffset
        
        if photoSize.width < scrollViewSize.width {
            contentOffset.x = (scrollView.contentSize.width - scrollViewSize.width) / 2
            scrollView.setContentOffset(contentOffset, animated: true)
        }

        if photoSize.height < scrollViewSize.height {
            contentOffset.y = (scrollView.contentSize.height - scrollViewSize.height) / 2
            scrollView.setContentOffset(contentOffset, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let photoSize = originalImageSize()
        let scrollViewSize = scrollView.frame.size
        var contentOffset = scrollView.contentOffset
        
        if photoSize.width < scrollViewSize.width {
            contentOffset.x = (scrollView.contentSize.width - scrollViewSize.width) / 2
            UIView.animate(withDuration: 0.3) {
                scrollView.setContentOffset(contentOffset, animated: false)
            }
        }

        if photoSize.height < scrollViewSize.height {
            contentOffset.y = (scrollView.contentSize.height - scrollViewSize.height) / 2
            UIView.animate(withDuration: 0.3) {
                scrollView.setContentOffset(contentOffset, animated: false)
            }
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
