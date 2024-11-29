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
            registerStorage()
            registerRepositoryDependency()
            try registerUseCaseDependency()
            try registerViewModelFactoryDependency()
        } catch let error as MHCoreError {
            MHLogger.error("\(error.description)")
        } catch {
            MHLogger.error("\(error.localizedDescription)")
        }
    }
    private func registerStorage() {
        let coreDataStorage = CoreDataStorage()
        DIContainer.shared.register(
            CoreDataStorage.self,
            object: coreDataStorage
        )
        DIContainer.shared.register(
            CoreDataBookCoverStorage.self,
            object: CoreDataBookCoverStorage(coreDataStorage: coreDataStorage)
        )
        DIContainer.shared.register(
            CoreDataBookStorage.self,
            object: CoreDataBookStorage(coreDataStorage: coreDataStorage)
        )
        DIContainer.shared.register(
            MHFileManager.self,
            object: MHFileManager(directoryType: .documentDirectory)
        )
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
        guard let bookCoverStorage = try? DIContainer.shared.resolve(CoreDataBookCoverStorage.self) else { return }
        DIContainer.shared.register(
            LocalBookCoverRepository.self,
            object: LocalBookCoverRepository(storage: bookCoverStorage)
        )
        guard let bookStorage = try? DIContainer.shared.resolve(CoreDataBookStorage.self) else { return }
        DIContainer.shared.register(
            BookRepository.self,
            object: LocalBookRepository(storage: bookStorage)
        )
        guard let fileManager = try? DIContainer.shared.resolve(MHFileManager.self) else { return }
        DIContainer.shared.register(
            MediaRepository.self,
            object: LocalMediaRepository(storage: fileManager)
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
        
        // MARK: - EditBook UseCase
        let bookRepository = try DIContainer.shared.resolve(BookRepository.self)
        DIContainer.shared.register(
            FetchBookUseCase.self,
            object: DefaultFetchBookUseCase(repository: bookRepository)
        )
        DIContainer.shared.register(
            UpdateBookUseCase.self,
            object: DefaultUpdateBookUseCase(repository: bookRepository)
        )
        let mediaRepository = try DIContainer.shared.resolve(MediaRepository.self)
        DIContainer.shared.register(
            PersistentlyStoreMediaUseCase.self,
            object: DefaultPersistentlyStoreMediaUseCase(repository: mediaRepository)
        )
        DIContainer.shared.register(
            CreateMediaUseCase.self,
            object: DefaultCreateMediaUseCase(repository: mediaRepository)
        )
        DIContainer.shared.register(
            FetchMediaUseCase.self,
            object: DefaultFetchMediaUseCase(repository: mediaRepository)
        )
        DIContainer.shared.register(
            DeleteMediaUseCase.self,
            object: DefaultDeleteMediaUseCase(repository: mediaRepository)
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
        
        // MARK: - EditBook ViewModel
        let fetchBookUseCase = try DIContainer.shared.resolve(FetchBookUseCase.self)
        let updateBookUseCase = try DIContainer.shared.resolve(UpdateBookUseCase.self)
        let storeBookUseCase = try DIContainer.shared.resolve(PersistentlyStoreMediaUseCase.self)
        let createMediaUseCase = try DIContainer.shared.resolve(CreateMediaUseCase.self)
        let fetchMediaUseCase = try DIContainer.shared.resolve(FetchMediaUseCase.self)
        let deleteMediaUseCase = try DIContainer.shared.resolve(DeleteMediaUseCase.self)
        DIContainer.shared.register(
            EditBookViewModelFactory.self,
            object: EditBookViewModelFactory(
                fetchBookUseCase: fetchBookUseCase,
                updateBookUseCase: updateBookUseCase,
                storeBookUseCase: storeBookUseCase,
                createMediaUseCase: createMediaUseCase,
                fetchMediaUseCase: fetchMediaUseCase,
                deleteMediaUseCase: deleteMediaUseCase
            )
        )
    }
}
