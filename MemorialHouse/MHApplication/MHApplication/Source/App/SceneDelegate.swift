import UIKit
import MHFoundation
import MHPresentation

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let initialViewController: UIViewController
        if let houseName = UserDefaults.standard.object(forKey: Constant.houseNameUserDefaultKey) as? String {
            let viewModel = HomeViewModel(houseName: houseName)
            initialViewController = HomeViewController(viewModel: viewModel)
        } else {
            initialViewController = RegisterViewController()
        }
        
        let navigationController = UINavigationController(rootViewController: initialViewController)
        navigationController.navigationBar.isHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
