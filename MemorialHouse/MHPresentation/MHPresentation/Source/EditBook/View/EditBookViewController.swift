import UIKit

final class EditBookViewController: UIViewController {
    // MARK: - Property
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
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureNavigationBar()
        configureAddSubView()
        configureConstraints()
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
            bottom: view.safeAreaLayoutGuide.bottomAnchor, constantBottom: 20,
            height: 40
        )
        
        // publishButton
        publishButton.setAnchor(
            bottom: buttonStackView.bottomAnchor,
            trailing: editPageTableView.trailingAnchor, constantTrailing: 15,
            width: 55,
            height: 40
        )
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
