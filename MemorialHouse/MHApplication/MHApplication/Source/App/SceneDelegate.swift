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
        
        let initialViewController = createInitialViewController()
        window?.rootViewController = UINavigationController(rootViewController: initialViewController)
        window?.makeKeyAndVisible()
    }
    
    private func createInitialViewController() -> UIViewController {
        if isUserRegistered() {
            return createHomeViewController()
        } else {
            return createRegisterViewController()
        }
    }
    
    private func isUserRegistered() -> Bool {
        return UserDefaults.standard.object(forKey: Constant.houseNameUserDefaultKey) != nil
    }
    
    private func createHomeViewController() -> UIViewController {
        do {
            let homeViewModelFactory = try DIContainer.shared.resolve(HomeViewModelFactory.self)
            let homeViewModel = homeViewModelFactory.make()
            return HomeViewController(viewModel: homeViewModel)
        } catch {
            MHLogger.error("HomeViewModelFactory 해제 실패: \(error.localizedDescription)")
            return createErrorViewController()
        }
    }
    
    private func createRegisterViewController() -> UIViewController {
        do {
            let registerViewModelFactory = try DIContainer.shared.resolve(RegisterViewModelFactory.self)
            let registerViewModel = registerViewModelFactory.make()
            return RegisterViewController(viewModel: registerViewModel)
        } catch {
            MHLogger.error("CreateMemorialHouseNameUseCase 해제 실패: \(error.localizedDescription)")
            return createErrorViewController()
        }
    }
    
    private func createErrorViewController() -> UIViewController {
        let errorViewController = UIViewController()
        errorViewController.view.backgroundColor = .systemRed
        let label = UILabel()
        label.text = "오류가 발생했습니다."
        label.textColor = .white
        label.textAlignment = .center
        label.frame = errorViewController.view.bounds
        errorViewController.view.addSubview(label)
        return errorViewController
    }
    
    private func registerDependency() {
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
            CoreDataBookCoverStorage.self,
            object: CoreDataBookCoverStorage(coreDataStorage: coreDataStorage)
        )
        DIContainer.shared.register(
            CoreDataBookStorage.self,
            object: CoreDataBookStorage(coreDataStorage: coreDataStorage)
        )
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
        DIContainer.shared.register(
            MemorialHouseNameStorage.self,
            object: UserDefaultsMemorialHouseNameStorage()
        )
        DIContainer.shared.register(
            MHFileManager.self,
            object: MHFileManager(directoryType: .documentDirectory)
        )
    }
    
    private func registerRepositoryDependency() throws {
        let memorialHouseNameStorage = try DIContainer.shared.resolve(MemorialHouseNameStorage.self)
        DIContainer.shared.register(
            MemorialHouseNameRepository.self,
            object: LocalMemorialHouseNameRepository(storage: memorialHouseNameStorage)
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
        let fileManager = try DIContainer.shared.resolve(MHFileManager.self)
        DIContainer.shared.register(
            MediaRepository.self,
            object: LocalMediaRepository(storage: fileManager)
        )
    }
    
    private func registerUseCaseDependency() throws {
        // MARK: MemorialHouse UseCase
        let memorialHouseNameRepository = try DIContainer.shared.resolve(MemorialHouseNameRepository.self)
        DIContainer.shared.register(
            CreateMemorialHouseNameUseCase.self,
            object: DefaultCreateMemorialHouseNameUseCase(repository: memorialHouseNameRepository)
        )
        DIContainer.shared.register(
            FetchMemorialHouseNameUseCase.self,
            object: DefaultFetchMemorialHouseNameUseCase(repository: memorialHouseNameRepository)
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
        let mediaRepository = try DIContainer.shared.resolve(MediaRepository.self)
        DIContainer.shared.register(
            CreateBookUseCase.self,
            object: DefaultCreateBookUseCase(repository: bookRepository,
                                             mediaRepository: mediaRepository)
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
        
        // MARK: - BookCover UseCase
        let bookCoverRepository = try DIContainer.shared.resolve(BookCoverRepository.self)
        DIContainer.shared.register(
            CreateBookCoverUseCase.self,
            object: DefaultCreateBookCoverUseCase(repository: bookCoverRepository)
        )
        DIContainer.shared.register(
            FetchAllBookCoverUseCase.self,
            object: DefaultFetchAllBookCoverUseCase(repository: bookCoverRepository)
        )
        DIContainer.shared.register(
            FetchBookCoverUseCase.self,
            object: DefaultFetchBookCoverUseCase(repository: bookCoverRepository)
        )
        DIContainer.shared.register(
            UpdateBookCoverUseCase.self,
            object: DefaultUpdateBookCoverUseCase(repository: bookCoverRepository)
        )
        DIContainer.shared.register(
            DeleteBookCoverUseCase.self,
            object: DefaultDeleteBookCoverUseCase(repository: bookCoverRepository)
        )
        
        // MARK: - EditBook UseCase
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
        // MARK: Register ViewModel
        let createMemorialHouseNameUseCase = try DIContainer.shared.resolve(CreateMemorialHouseNameUseCase.self)
        DIContainer.shared.register(
            RegisterViewModelFactory.self,
            object: RegisterViewModelFactory(createMemorialHouseNameUseCase: createMemorialHouseNameUseCase)
        )
        
        // MARK: Home ViewModel
        let fetchMemorialHouseNameUseCase = try DIContainer.shared.resolve(FetchMemorialHouseNameUseCase.self)
        let fetchAllBookCoverUseCase = try DIContainer.shared.resolve(FetchAllBookCoverUseCase.self)
        let updateBookCoverUseCase = try DIContainer.shared.resolve(UpdateBookCoverUseCase.self)
        let deleteBookCoverUseCase = try DIContainer.shared.resolve(DeleteBookCoverUseCase.self)
        DIContainer.shared.register(
            HomeViewModelFactory.self,
            object: HomeViewModelFactory(
                fetchMemorialHouseNameUseCase: fetchMemorialHouseNameUseCase,
                fetchAllBookCoverUseCase: fetchAllBookCoverUseCase,
                updateBookCoverUseCase: updateBookCoverUseCase,
                deleteBookCoverUseCase: deleteBookCoverUseCase
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
        
        // MARK: - Create BookCover ViewModel
        let createBookCoverUseCase = try DIContainer.shared.resolve(CreateBookCoverUseCase.self)
        let createBookUseCase = try DIContainer.shared.resolve(CreateBookUseCase.self)
        let deleteBookUseCase = try DIContainer.shared.resolve(DeleteBookUseCase.self)
        DIContainer.shared.register(
            CreateBookCoverViewModelFactory.self,
            object: CreateBookCoverViewModelFactory(
                fetchMemorialHouseNameUseCase: fetchMemorialHouseNameUseCase,
                createBookCoverUseCase: createBookCoverUseCase,
                deleteBookCoverUseCase: deleteBookCoverUseCase,
                createBookUseCase: createBookUseCase,
                deleteBookUseCase: deleteBookUseCase
            )
        )
        
        // MARK: - Modify BookCover ViewModel
        let fetchBookCoverUseCase = try DIContainer.shared.resolve(FetchBookCoverUseCase.self)
        DIContainer.shared.register(
            ModifyBookCoverViewModelFactory.self,
            object: ModifyBookCoverViewModelFactory(
                fetchMemorialHouseNameUseCase: fetchMemorialHouseNameUseCase,
                fetchBookCoverUseCase: fetchBookCoverUseCase,
                updateBookCoverUseCase: updateBookCoverUseCase
            )
        )
        
        // MARK: - Book ViewModel
        let fetchBookUseCase = try DIContainer.shared.resolve(FetchBookUseCase.self)
        DIContainer.shared.register(
            BookViewModelFactory.self,
            object: BookViewModelFactory(fetchBookUseCase: fetchBookUseCase)
        )
        
        // MARK: - EditBook ViewModel
        let updateBookUseCase = try DIContainer.shared.resolve(UpdateBookUseCase.self)
        let storeMediaUseCase = try DIContainer.shared.resolve(PersistentlyStoreMediaUseCase.self)
        let createMediaUseCase = try DIContainer.shared.resolve(CreateMediaUseCase.self)
        let fetchMediaUseCase = try DIContainer.shared.resolve(FetchMediaUseCase.self)
        let deleteMediaUseCase = try DIContainer.shared.resolve(DeleteMediaUseCase.self)
        DIContainer.shared.register(
            EditBookViewModelFactory.self,
            object: EditBookViewModelFactory(
                fetchBookUseCase: fetchBookUseCase,
                updateBookUseCase: updateBookUseCase,
                storeMediaUseCase: storeMediaUseCase,
                createMediaUseCase: createMediaUseCase,
                fetchMediaUseCase: fetchMediaUseCase,
                deleteMediaUseCase: deleteMediaUseCase
            )
        )
        
        // MARK: - Page ViewModel
        DIContainer.shared.register(
            ReadPageViewModelFactory.self,
            object: ReadPageViewModelFactory(fetchMediaUseCase: fetchMediaUseCase)
        )
        
        // MARK: - EditPhoto ViewModel
        DIContainer.shared.register(
            EditPhotoViewModelFactory.self,
            object: EditPhotoViewModelFactory(createMediaUseCase: createMediaUseCase)
        )
    }
}
