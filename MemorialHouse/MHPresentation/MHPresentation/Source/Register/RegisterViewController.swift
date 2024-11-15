import UIKit
import MHFoundation
import Combine

public final class RegisterViewController: UIViewController {
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Property
    var registerView = MHRegisterView()
    var username = ""
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureAddSubview()
        configureConstraints()
    }
    
    private func setup() {
        view.backgroundColor = .baseBackground
        
        MHRegisterView.textfieldSubject.sink { text in
            self.username = text
        }.store(in: &subscriptions)
        
        MHRegisterView.buttonSubject.sink { isValid in
            if isValid {
                let homeViewController = HomeViewController(viewModel: HomeViewModel(houseName: self.username))
                self.navigationController?.pushViewController(homeViewController, animated: false)
                self.navigationController?.viewControllers.removeFirst()    // inactive back to register view
            } else {
                // TODO: - 기록소 이름 조건이 안맞는 부분 처리
            }
        }.store(in: &subscriptions)
        
        registerView = MHRegisterView(
            frame: CGRect.init(x: 0, y: 0, width: view.bounds.width - 50, height: view.bounds.height - 640))
    }
    
    private func configureAddSubview() {
        self.view.addSubview(registerView)
    }
    
    private func configureConstraints() {
        registerView.setTop(anchor: self.view.topAnchor, constant: 320)
        registerView.setBottom(anchor: self.view.bottomAnchor, constant: 320)
        registerView.setLeading(anchor: self.view.leadingAnchor, constant: 25)
        registerView.setTrailing(anchor: self.view.trailingAnchor, constant: 25)
    }
}
