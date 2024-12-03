import MHFoundation
import MHCore
import UIKit
import Combine

// TODO: - 페이지 없애는 기능 추가
final class EditBookViewController: UIViewController {
    enum Mode {
        case create
        case modify
    }
    // MARK: - Constant
    static let buttonBottomConstant: CGFloat = -20
    
    // MARK: - ViewComponent
    private let editPageTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(EditPageCell.self, forCellReuseIdentifier: EditPageCell.identifier)
        
        return tableView
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
        
        button.isHidden = true // 추후 로직 추가하면 보여주기
        
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
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        stackView.backgroundColor = .clear
        
        return stackView
    }()
    private let addPageButton: UIButton = {
        let button = UIButton()
        let title = NSAttributedString(
            string: "페이지 추가",
            attributes: [
                .font: UIFont.ownglyphBerry(size: 20),
                .foregroundColor: UIColor.mhTitle
            ]
        )
        button.setAttributedTitle(title, for: .normal)
        button.backgroundColor = .clear
        
        return button
    }()
    private var buttonStackViewBottomConstraint: NSLayoutConstraint?

    // MARK: - Property
    private let viewModel: EditBookViewModel
    private let input = PassthroughSubject<EditBookViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let mode: Mode
    
    // MARK: - Initializer
    init(
        viewModel: EditBookViewModel,
        mode: Mode = .create
    ) {
        self.viewModel = viewModel
        self.mode = mode
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        guard let viewModel = try? DIContainer.shared.resolve(EditBookViewModelFactory.self) else { return nil }
        self.viewModel = viewModel.make(bookID: .init())
        self.mode = .create
        
        super.init(coder: coder)
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureNavigationBar()
        configureAddSubView()
        configureConstraints()
        configureKeyboard()
        configureBinding()
        configureButtonAction()
        input.send(.viewDidLoad)
    }
    
    // MARK: - Setup & Configuration
    private func setup() {
        view.backgroundColor = .baseBackground
        
        editPageTableView.delegate = self
        editPageTableView.dataSource = self
    }
    private func configureNavigationBar() {
        // 공통 스타일 정의
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ownglyphBerry(size: 17),
            .foregroundColor: UIColor.mhTitle
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ownglyphBerry(size: 17),
            .foregroundColor: UIColor.mhTitle
        ]
        
        // 네비게이션 왼쪽 아이템
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "뒤로가기",
            normal: normalAttributes,
            selected: selectedAttributes
        ) { [weak self] in
            let alert = UIAlertController(
                title: "작성을 취소하시겠습니까?",
                message: "작성 중인 내용은 저장되지 않습니다.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                self?.input.send(.didCancelButtonTapped)
            })
            self?.present(alert, animated: true)
        }
        
        // 네비게이션 오른쪽 아이템
        switch mode {
        case .create:
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "기록 마치기",
                normal: normalAttributes,
                selected: selectedAttributes
            ) { [weak self] in
                self?.input.send(.didSaveButtonTapped)
            }
        case .modify:
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "수정 마치기",
                normal: normalAttributes,
                selected: selectedAttributes
            ) { [weak self] in
                self?.input.send(.didSaveButtonTapped)
            }
        }
    }
    private func configureAddSubView() {
        view.addSubview(editPageTableView)
        
        buttonStackView.addArrangedSubview(addImageButton)
        buttonStackView.addArrangedSubview(addTextButton)
        buttonStackView.addArrangedSubview(addVideoButton)
        buttonStackView.addArrangedSubview(addAudioButton)
        view.addSubview(buttonStackView)
        
        view.addSubview(addPageButton)
    }
    private func configureConstraints() {
        editPageTableView.setAnchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            bottom: buttonStackView.topAnchor, constantBottom: 10,
            trailing: view.trailingAnchor
        )
        
        buttonStackView.setAnchor(
            leading: editPageTableView.leadingAnchor, constantLeading: 10,
            height: 40
        )
        buttonStackViewBottomConstraint
        = buttonStackView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: Self.buttonBottomConstant
        )
        buttonStackViewBottomConstraint?.isActive = true
        
        addPageButton.setAnchor(
            bottom: buttonStackView.bottomAnchor,
            trailing: editPageTableView.trailingAnchor, constantTrailing: 15
        )
    }
    private func configureKeyboard() {
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
        // 스크롤이 될 때 키보드 내려가게 설정
        editPageTableView.keyboardDismissMode = .onDrag
    }
    private func configureBinding() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .updateViewController(let title):
                    self?.navigationItem.title = title
                    self?.editPageTableView.reloadData()
                case .saveDone:
                    guard let self else { return }
                    switch self.mode {
                    case .create:
                        self.navigationController?.popToRootViewController(animated: true)
                    case .modify:
                        self.navigationController?.popViewController(animated: true)
                    }
                case .revokeDone:
                    self?.navigationController?.popViewController(animated: true)
                case .error(let message):
                    self?.showErrorAlert(with: message)
                }
            }
            .store(in: &cancellables)
    }
    private func configureButtonAction() {
        let addImageAction = UIAction { [weak self] _ in
            let albumViewModel = CustomAlbumViewModel()
            let customAlbumViewController = CustomAlbumViewController(
                viewModel: albumViewModel,
                mediaType: .image,
                mode: .editPage,
                videoSelectCompletionHandler: nil
            ) { imageData, creationDate, caption in
                let attributes: [String: any Sendable] = [
                    Constant.photoCreationDate: creationDate?.toString(),
                    Constant.photoCaption: caption
                ]
                self?.input.send(.didAddMediaWithData(type: .image, attributes: attributes, data: imageData))
            }
            let navigationViewController = UINavigationController(rootViewController: customAlbumViewController)
            navigationViewController.modalPresentationStyle = .fullScreen
            self?.present(navigationViewController, animated: true)
        }
        addImageButton.addAction(addImageAction, for: .touchUpInside)
        
        let addVideoAction = UIAction { [weak self] _ in
            let albumViewModel = CustomAlbumViewModel()
            let customAlbumViewController = CustomAlbumViewController(
                viewModel: albumViewModel,
                mediaType: .video,
                videoSelectCompletionHandler: { url in
                    self?.input.send(.didAddMediaInURL(type: .video, attributes: nil, url: url))
                }
            )
            
            let navigationViewController = UINavigationController(rootViewController: customAlbumViewController)
            navigationViewController.modalPresentationStyle = .fullScreen
            self?.present(navigationViewController, animated: true)
        }
        addVideoButton.addAction(addVideoAction, for: .touchUpInside)
        
        let addAudioAction = UIAction { [weak self] _ in
            // TODO: - 오디오 추가 로직
        }
        addAudioButton.addAction(addAudioAction, for: .touchUpInside)
        
        let addPageAction = UIAction { [weak self] _ in
            self?.input.send(.addPageButtonTapped)
        }
        addPageButton.addAction(addPageAction, for: .touchUpInside)
    }
    
    // MARK: - Keyboard Appear & Hide
    @objc private func keyboardWillAppear(_ notification: Notification) {
        guard let keyboardInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey],
              let keyboardSize = keyboardInfo as? CGRect else { return }
        let bottomConstant = -(keyboardSize.height - view.safeAreaInsets.bottom + 10)
        buttonStackViewBottomConstraint?.constant = bottomConstant
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    @objc private func keyboardWillHide() {
        buttonStackViewBottomConstraint?.constant = Self.buttonBottomConstant
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDelegate
extension EditBookViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.safeAreaLayoutGuide.layoutFrame.height - buttonStackView.frame.height - 40
    }
}

// MARK: - UITableViewDataSource
extension EditBookViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfPages()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EditPageCell.identifier,
            for: indexPath) as? EditPageCell
        else { return UITableViewCell() }
        
        let editPageViewModel = viewModel.editPageViewModel(at: indexPath.row)
        cell.configure(viewModel: editPageViewModel)
        
        return cell
    }
}
