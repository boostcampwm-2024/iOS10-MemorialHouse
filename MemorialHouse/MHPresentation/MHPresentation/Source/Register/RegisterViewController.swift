import Combine
import UIKit
import MHCore
import MHDomain
import MHFoundation

public final class RegisterViewController: UIViewController {
    // MARK: - Property
    private var viewModel: RegisterViewModel
    private let input = PassthroughSubject<RegisterViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let coverImageView: UIImageView = {
        let backgroundImageView = UIImageView()
        backgroundImageView.image = .registerBook
        
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
        textLabel.adjustsFontSizeToFitWidth = true
        
        return textLabel
    }()
    private let mhRegisterView = MHRegisterView()
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
        guard let createMHNameUseCase = try? DIContainer.shared.resolve(CreateMemorialHouseNameUseCase.self) else {
            MHLogger.error("CreateMemorialHouseNameUseCase resolve 실패")
            return nil
        }
        self.viewModel = RegisterViewModel(createMemorialHouseNameUseCase: createMHNameUseCase)
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
        hideKeyboardWhenTappedView()
        mhRegisterView.registerTextField.delegate = self

        addTouchEventToRegisterButton(registerButton)
        mhRegisterView.configure { [weak self] text in
            guard let self else { return }
            self.input.send(.registerTextFieldEdited(text: text))
        }
        coverImageView.isUserInteractionEnabled = true
        registerButton.isEnabled = false
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output.sink { [weak self] event in
            switch event {
            case .registerButtonEnabled(let isEnabled):
                self?.registerButton.isEnabled = isEnabled
            case .moveToHome:
                self?.moveHome()
            case .createFailure(let errorMessage):
                self?.handleError(with: errorMessage)
            }
        }.store(in: &cancellables)
    }
    
    private func moveHome() {
        do {
            let homeViewModelFactory = try DIContainer.shared.resolve(HomeViewModelFactory.self)
            let homeViewModel = homeViewModelFactory.make()
            let homeViewController = HomeViewController(viewModel: homeViewModel)
            navigationController?.pushViewController(homeViewController, animated: false)
            navigationController?.viewControllers.removeFirst()
        } catch {
            MHLogger.error(error.localizedDescription)
            handleError(with: "홈 화면으로 이동 중에 오류가 발생했습니다.")
        }
    }
    
    private func handleError(with errorMessage: String) {
        let alertController = UIAlertController(
            title: "에러",
            message: errorMessage,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "확인", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
    private func configureAddSubview() {
        view.addSubview(coverImageView)
        view.addSubview(registerTextLabel)
        view.addSubview(mhRegisterView)
        view.addSubview(registerButton)
    }
    
    private func configureConstraints() {
        coverImageView.setCenter(view: view)
        coverImageView.setWidth(view.frame.width - 60)
        coverImageView.setHeight(250)
        
        registerTextLabel.setAnchor(
            top: coverImageView.topAnchor, constantTop: 38,
            leading: coverImageView.leadingAnchor, constantLeading: 80,
            trailing: coverImageView.trailingAnchor, constantTrailing: 40
        )
        
        let registerTextFieldBackground = mhRegisterView.embededInDefaultBackground()
        coverImageView.addSubview(registerTextFieldBackground)
        registerTextFieldBackground.setAnchor(
            top: registerTextLabel.bottomAnchor, constantTop: 24,
            leading: coverImageView.leadingAnchor, constantLeading: 52,
            trailing: coverImageView.trailingAnchor, constantTrailing: 28,
            height: 60
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
            bottom: coverImageView.bottomAnchor, constantBottom: 14,
            trailing: coverImageView.trailingAnchor, constantTrailing: 17,
            width: 60,
            height: 36
        )
    }
    
    private func addTouchEventToRegisterButton(_ button: UIButton) {
        let uiAction = UIAction { [weak self] _ in
            guard let self, let memorialHouseName = self.mhRegisterView.registerTextField.text else { return }
            self.input.send(.registerButtonTapped(memorialHouseName: memorialHouseName))
        }
        registerButton.addAction(uiAction, for: .touchUpInside)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
