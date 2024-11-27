import UIKit
import MHCore
import MHData
import MHDomain
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
        registerDependency()
        
        var initialViewController: UIViewController = RegisterViewController(viewModel: RegisterViewModel())
        if UserDefaults.standard.object(forKey: Constant.houseNameUserDefaultKey) != nil {
            do {
                let viewModelFactory = try DIContainer.shared.resolve(HomeViewModelFactory.self)
                let viewModel = viewModelFactory.make()
                initialViewController = HomeViewController(viewModel: viewModel)
            } catch {
                MHLogger.error(error.localizedDescription)
            }
        }
        
        let navigationController = UINavigationController(rootViewController: initialViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func registerDependency() {
        do {
            DIContainer.shared.register(
                MemorialHouseRepository.self,
                object: DefaultMemorialHouseRepository()
            )
            
            let memorialHouseRepository = try DIContainer.shared.resolve(MemorialHouseRepository.self)
            DIContainer.shared.register(
                FetchMemorialHouseUseCase.self,
                object: DefaultFetchMemorialHouseUseCase(repository: memorialHouseRepository)
            )
            
            let fetchMemorialHouseUseCase = try DIContainer.shared.resolve(FetchMemorialHouseUseCase.self)
            DIContainer.shared.register(
                HomeViewModelFactory.self,
                object: HomeViewModelFactory(fetchMemorialHouseUseCase: fetchMemorialHouseUseCase)
            )
        } catch let error as MHCoreError {
            MHLogger.error("\(error.description)")
        } catch {
            MHLogger.error("\(error.localizedDescription)")
        }
    }
}
