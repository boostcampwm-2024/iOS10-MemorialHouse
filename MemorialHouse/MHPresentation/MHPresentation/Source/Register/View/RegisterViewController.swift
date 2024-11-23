import Combine
import UIKit
import MHCore
import MHDomain
import MHFoundation

public final class RegisterViewController: UIViewController {
    // MARK: - Property
    private var viewModel = RegisterViewModel()
    private let input = PassthroughSubject<RegisterViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let coverImageView: UIImageView = {
        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage.pinkBook
        
        return backgroundImageView
    }()
    private let registerTextLabel: UILabel = {
        let registerFont = UIFont.ownglyphBerry(size: 24)
        
        let textLabel = UILabel()
        textLabel.text = """
                        추억을 간직할
                        기록소 이름을 작성해주세요
                        """
        textLabel.textAlignment = .center
        textLabel.font = registerFont
        textLabel.numberOfLines = 2
        
        return textLabel
    }()
    private let registerTextField: UITextField = {
        let registerFont = UIFont.ownglyphBerry(size: 12)
        
        let textField = UITextField()
        textField.font = registerFont
        
        var attributedText = AttributedString(stringLiteral: "기록소")
        attributedText.font = registerFont
        textField.attributedPlaceholder = NSAttributedString(attributedText)
        
        return textField
    }()
    private let registerButton: UIButton = {
        let registerButton = UIButton(type: .custom)
        
        var attributedString = AttributedString(stringLiteral: "다음")
        attributedString.font = UIFont.ownglyphBerry(size: 16)
        attributedString.foregroundColor = UIColor.black
        registerButton.setAttributedTitle(NSAttributedString(attributedString), for: .normal)
        
        var disabledAttributedString = AttributedString(stringLiteral: "다음")
        disabledAttributedString.font = UIFont.ownglyphBerry(size: 16)
        disabledAttributedString.foregroundColor = UIColor.gray
        registerButton.setAttributedTitle(NSAttributedString(disabledAttributedString), for: .disabled)
        
        registerButton.backgroundColor = .mhSection
        registerButton.layer.borderColor = UIColor.mhBorder.cgColor
        registerButton.layer.borderWidth = 1
        registerButton.layer.cornerRadius = 12
        
        return registerButton
    }()
    
    // MARK: - Initializer
    public init(viewModel: RegisterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = RegisterViewModel()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
        configureAddSubview()
        configureConstraints()
    }
    
    private func setup() {
        view.backgroundColor = .baseBackground

        addTouchEventToRegisterButton(registerButton)
        addEditingChangedEventToRegisterTextField(registerTextField)
        coverImageView.isUserInteractionEnabled = true
        registerButton.isEnabled = false
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output.sink { [weak self] event in
            switch event {
            case .registerButtonEnabled(let isEnabled):
                self?.registerButton.isEnabled = isEnabled
            case .moveToHome(let houseName):
                do {
                    let homeViewModelFactory = try DIContainer.shared.resolve(HomeViewModelFactory.self)
                    let homeViewModel = homeViewModelFactory.make()
                    let homeViewController = HomeViewController(viewModel: homeViewModel)
                    self?.navigationController?.pushViewController(homeViewController, animated: false)
                    self?.navigationController?.viewControllers.removeFirst()
                } catch {
                    MHLogger.error(error.localizedDescription)
                }
            }
        }.store(in: &cancellables)
    }
    
    private func configureAddSubview() {
        view.addSubview(coverImageView)
        view.addSubview(registerTextLabel)
        view.addSubview(registerTextField)
        view.addSubview(registerButton)
    }
    
    private func configureConstraints() {
        coverImageView.setCenter(view: view)
        coverImageView.setWidth(view.frame.width - 50)
        coverImageView.setHeight(240)
        
        registerTextLabel.setAnchor(
            top: coverImageView.topAnchor,
            leading: coverImageView.leadingAnchor, constantLeading: 80,
            trailing: coverImageView.trailingAnchor, constantTrailing: 40,
            height: 96
        )
        
        let registerTextFieldBackground = registerTextField.embededInDefaultBackground(
            with: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 5)
        )
        coverImageView.addSubview(registerTextFieldBackground)
        registerTextFieldBackground.setAnchor(
            top: registerTextLabel.bottomAnchor,
            leading: coverImageView.leadingAnchor, constantLeading: 80,
            trailing: coverImageView.trailingAnchor, constantTrailing: 40,
            height: 44
        )
        
        let registerButtonBackground = UIView()
        registerButtonBackground.backgroundColor = .mhSection
        registerButtonBackground.layer.cornerRadius = 12 + 1
        registerButtonBackground.clipsToBounds = true
        registerButtonBackground.addSubview(registerButton)
        registerButton.setAnchor(
            top: registerButtonBackground.topAnchor, constantTop: 3,
            leading: registerButtonBackground.leadingAnchor, constantLeading: 4,
            bottom: registerButtonBackground.bottomAnchor, constantBottom: 3,
            trailing: registerButtonBackground.trailingAnchor, constantTrailing: 4
        )
        
        coverImageView.addSubview(registerButtonBackground)
        registerButtonBackground.setAnchor(
            top: registerTextFieldBackground.bottomAnchor, constantTop: 10,
            leading: view.leadingAnchor, constantLeading: 260,
            width: 60,
            height: 36
        )
    }
    
    private func addTouchEventToRegisterButton(_ button: UIButton) {
        let uiAction = UIAction { [weak self] _ in
            guard let self, let text = self.registerTextField.text else { return }
            self.input.send(.registerButtonTapped(text: text))
        }
        registerButton.addAction(uiAction, for: .touchUpInside)
    }
    
    private func addEditingChangedEventToRegisterTextField(_ textfield: UITextField) {
        let uiAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.input.send(.registerTextFieldEdited(text: textfield.text))
        }
        registerTextField.addAction(uiAction, for: .editingChanged)
    }
}
