import UIKit
import Combine

final class EditBookViewController: UIViewController {
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
    private let publishButton: UIButton = {
        let button = UIButton()
        button.setImage(.publishButton, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .clear
        
        return button
    }()
    private var buttonStackViewBottomConstraint: NSLayoutConstraint?

    // MARK: - Property
    private let viewModel: EditBookViewModel
    private let input = PassthroughSubject<EditBookViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(viewModel: EditBookViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        self.viewModel = EditBookViewModel()
        
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
    }
    
    // MARK: - Setup & Configuration
    private func setup() {
        view.backgroundColor = .baseBackground
        
        editPageTableView.delegate = self
        editPageTableView.dataSource = self
    }
    private func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    private func configureAddSubView() {
        // editPageTableView
        view.addSubview(editPageTableView)
        
        // buttonStackView
        buttonStackView.addArrangedSubview(addImageButton)
        buttonStackView.addArrangedSubview(addTextButton)
        buttonStackView.addArrangedSubview(addVideoButton)
        buttonStackView.addArrangedSubview(addAudioButton)
        view.addSubview(buttonStackView)
        
        // publishButton
        view.addSubview(publishButton)
    }
    private func configureConstraints() {
        // tableView
        editPageTableView.setAnchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            bottom: buttonStackView.topAnchor, constantBottom: 10,
            trailing: view.trailingAnchor
        )
        
        // buttonStackView
        buttonStackView.setAnchor(
            leading: editPageTableView.leadingAnchor, constantLeading: 10,
            height: 40
        )
        buttonStackViewBottomConstraint
        = buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Self.buttonBottomConstant)
        buttonStackViewBottomConstraint?.isActive = true
        
        // publishButton
        publishButton.setAnchor(
            bottom: buttonStackView.bottomAnchor,
            trailing: editPageTableView.trailingAnchor, constantTrailing: 15,
            width: 55,
            height: 40
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
    }
    private func configureBinding() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output.receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .setTableView:
                    self?.editPageTableView.reloadData()
                }
            }
            .store(in: &cancellables)
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

// MARK: - UIScrollViewDelegate
extension EditBookViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

// MARK: - UITableViewDelegate
extension EditBookViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource
extension EditBookViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EditPageCell.identifier,
            for: indexPath
        ) as? EditPageCell else { return UITableViewCell() }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height
    }
}
