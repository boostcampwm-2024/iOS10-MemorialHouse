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
            try registerStorageDepedency()
            try registerRepositoryDependency()
            try registerUseCaseDependency()
            try registerViewModelFactoryDependency()
        } catch let error as MHCoreError {
            MHLogger.error("\(error.description)")
        } catch {
            MHLogger.error("\(error.localizedDescription)")
        }
    }
    
    private func registerStorageDepedency() throws {
        DIContainer.shared.register(CoreDataStorage.self, object: CoreDataStorage())
                
        let coreDataStorage = try DIContainer.shared.resolve(CoreDataStorage.self)
        DIContainer.shared.register(
            BookCategoryStorage.self,
            object: CoreDataBookCategoryStorage(coreDataStorage: coreDataStorage)
        )
        DIContainer.shared.register(
            BookCoverStorage.self,
            object: CoreDataBookCoverStorage(coreDataStorage: coreDataStorage)
        )
        DIContainer.shared.register(
            BookStorage.self,
            object: CoreDataBookStorage(coreDataStorage: coreDataStorage)
        )
    }
    
    private func registerRepositoryDependency() throws {
        DIContainer.shared.register(
            MemorialHouseRepository.self,
            object: DefaultMemorialHouseRepository()
        )
        
        let bookCategoryStorage = try DIContainer.shared.resolve(BookCategoryStorage.self)
        DIContainer.shared.register(
            BookCategoryRepository.self,
            object: LocalBookCategoryRepository(storage: bookCategoryStorage)
        )
        let bookCoverStorage = try DIContainer.shared.resolve(BookCoverStorage.self)
        DIContainer.shared.register(
            BookCoverRepository.self,
            object: LocalBookCoverRepository(storage: bookCoverStorage)
        )
        let bookStorage = try DIContainer.shared.resolve(BookStorage.self)
        DIContainer.shared.register(
            BookRepository.self,
            object: LocalBookRepository(storage: bookStorage)
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
        let bookCategoryRepository = try DIContainer.shared.resolve(BookCategoryRepository.self)
        DIContainer.shared.register(
            CreateBookCategoryUseCase.self,
            object: DefaultCreateBookCategoryUseCase(repository: bookCategoryRepository)
        )
        DIContainer.shared.register(
            FetchBookCategoriesUseCase.self,
            object: DefaultFetchBookCategoriesUseCase(repository: bookCategoryRepository)
        )
        DIContainer.shared.register(
            UpdateBookCategoryUseCase.self,
            object: DefaultUpdateBookCategoryUseCase(repository: bookCategoryRepository)
        )
        DIContainer.shared.register(
            DeleteBookCategoryUseCase.self,
            object: DefaultDeleteBookCategoryUseCase(repository: bookCategoryRepository)
        )
        
        // MARK: - Book UseCase
        let bookRepository = try DIContainer.shared.resolve(BookRepository.self)
        DIContainer.shared.register(
            CreateBookUseCase.self,
            object: DefaultCreateBookUseCase(repository: bookRepository)
        )
        DIContainer.shared.register(
            FetchBookUseCase.self,
            object: DefaultFetchBookUseCase(repository: bookRepository)
        )
        DIContainer.shared.register(
            UpdateBookUseCase.self,
            object: DefaultUpdateBookUseCase(repository: bookRepository)
        )
        DIContainer.shared.register(
            DeleteBookUseCase.self,
            object: DefaultDeleteBookUseCase(repository: bookRepository)
        )
    }
    
    private func registerViewModelFactoryDependency() throws {
        // MARK: MemorialHouse ViewModel
        let fetchMemorialHouseUseCase = try DIContainer.shared.resolve(FetchMemorialHouseUseCase.self)
        let fetchBookCategoryUseCase = try DIContainer.shared.resolve(FetchBookCategoriesUseCase.self)
        DIContainer.shared.register(
            HomeViewModelFactory.self,
            object: HomeViewModelFactory(
                fetchMemorialHouseUseCase: fetchMemorialHouseUseCase,
                fetchCategoryUseCase: fetchBookCategoryUseCase
            )
        )
        
        // MARK: Category ViewModel
        let createBookCategoryUseCase = try DIContainer.shared.resolve(CreateBookCategoryUseCase.self)
        let fetchBookCategoriesUseCase = try DIContainer.shared.resolve(FetchBookCategoriesUseCase.self)
        let updateBookCategoryUseCase = try DIContainer.shared.resolve(UpdateBookCategoryUseCase.self)
        let deleteBookCategoryUseCase = try DIContainer.shared.resolve(DeleteBookCategoryUseCase.self)
        DIContainer.shared.register(
            BookCategoryViewModelFactory.self,
            object: BookCategoryViewModelFactory(
                createBookCategoryUseCase: createBookCategoryUseCase,
                fetchBookCategoriesUseCase: fetchBookCategoriesUseCase,
                updateBookCategoryUseCase: updateBookCategoryUseCase,
                deleteBookCategoryUseCase: deleteBookCategoryUseCase
            )
        )
        
        // MARK: - Book ViewModel
        let fetchBookUseCase = try DIContainer.shared.resolve(FetchBookUseCase.self)
        DIContainer.shared.register(
            BookViewModelFactory.self,
            object: BookViewModelFactory(fetchBookUseCase: fetchBookUseCase)
        )
        
        // MARK: - Page ViewModel
        DIContainer.shared.register(
            ReadPageViewModelFactory.self,
            object: ReadPageViewModelFactory()
        )
    }
}
