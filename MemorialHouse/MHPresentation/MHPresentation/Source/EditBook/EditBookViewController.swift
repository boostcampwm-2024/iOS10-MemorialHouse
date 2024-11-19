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
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        stackView.backgroundColor = .clear
        
        return stackView
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
        view.addSubview(editPageTableView)
        
        // buttonStackView
        buttonStackView.addArrangedSubview(addImageButton)
        buttonStackView.addArrangedSubview(addVideoButton)
        buttonStackView.addArrangedSubview(addTextButton)
        buttonStackView.addArrangedSubview(addAudioButton)
        view.addSubview(buttonStackView)
    }
    private func configureConstraints() {
        // talbeView
        editPageTableView.setAnchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            bottom: buttonStackView.topAnchor, constantBottom: 10,
            trailing: view.trailingAnchor
        )
        buttonStackView.setAnchor(
            leading: editPageTableView.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor, constantBottom: 20,
            trailing: editPageTableView.trailingAnchor,
            height: 40
        )
    }
    
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
