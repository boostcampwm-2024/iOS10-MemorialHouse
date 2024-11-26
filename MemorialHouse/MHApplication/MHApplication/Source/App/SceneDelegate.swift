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
            registerRepositoryDependency()
            try registerUseCaseDependency()
            try registerViewModelFactoryDependency()
        } catch let error as MHError {
            MHLogger.error("\(error.description)")
        } catch {
            MHLogger.error("\(error.localizedDescription)")
        }
    }
    
    private func registerRepositoryDependency() {
        DIContainer.shared.register(
            MemorialHouseRepository.self,
            object: DefaultMemorialHouseRepository()
        )
        DIContainer.shared.register(
            CategoryRepository.self,
            object: DefaultCategoryRepository()
        )
    }
    
    private func registerUseCaseDependency() throws {
        // MARK: MemorialHouse UseCase
        let memorialHouseRepository = try DIContainer.shared.resolve(MemorialHouseRepository.self)
        DIContainer.shared.register(
            FetchMemorialHouseUseCase.self,
            object: DefaultFetchMemorialHouseUseCase(repository: memorialHouseRepository)
        )
        
        // MARK: Category UseCase
        let categoryRepository = try DIContainer.shared.resolve(CategoryRepository.self)
        DIContainer.shared.register(
            CreateCategoryUseCase.self,
            object: DefaultCreateCategoryUseCase(repository: categoryRepository)
        )
        DIContainer.shared.register(
            FetchCategoriesUseCase.self,
            object: DefaultFetchCategoriesUseCase(repository: categoryRepository)
        )
        DIContainer.shared.register(
            UpdateCategoryUseCase.self,
            object: DefaultUpdateCategoryUseCase(repository: categoryRepository)
        )
        DIContainer.shared.register(
            DeleteCategoryUseCase.self,
            object: DefaultDeleteCategoryUseCase(repository: categoryRepository)
        )
    }
    
    private func registerViewModelFactoryDependency() throws {
        // MARK: MemorialHouse ViewModel
        let fetchMemorialHouseUseCase = try DIContainer.shared.resolve(FetchMemorialHouseUseCase.self)
        let fetchCategoryUseCase = try DIContainer.shared.resolve(FetchCategoriesUseCase.self)
        DIContainer.shared.register(
            HomeViewModelFactory.self,
            object: HomeViewModelFactory(
                fetchMemorialHouseUseCase: fetchMemorialHouseUseCase,
                fetchCategoryUseCase: fetchCategoryUseCase
            )
        )
        
        // MARK: Category ViewModel
        let createCategoryUseCase = try DIContainer.shared.resolve(CreateCategoryUseCase.self)
        let updateCategoryUseCase = try DIContainer.shared.resolve(UpdateCategoryUseCase.self)
        let deleteCategoryUseCase = try DIContainer.shared.resolve(DeleteCategoryUseCase.self)
        DIContainer.shared.register(
            CategoryViewModelFactory.self,
            object: CategoryViewModelFactory(
                createCategoryUseCase: createCategoryUseCase,
                updateCategoryUseCase: updateCategoryUseCase,
                deleteCategoryUseCase: deleteCategoryUseCase
            )
        )
    }
}
