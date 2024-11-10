import UIKit
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
        
        let initController: UIViewController
        if UserDefaults.standard.object(forKey: "houseName") == nil {
            initController = RegisterViewController()
        } else {
            initController = HomeViewController()
        }
        
        let navigationController = UINavigationController(rootViewController: initController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
