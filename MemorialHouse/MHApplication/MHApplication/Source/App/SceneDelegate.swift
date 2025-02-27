import UIKit
import MHCore
import MHData
import MHDomain
import Foundation
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
        Task {
            await registerDependency()
            
            let initialViewController = await createInitialViewController()
            let navigationController = UINavigationController(rootViewController: initialViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }
    }
    
    // MARK: - 시작화면 설정
    private func createInitialViewController() async -> UIViewController {
        return await isUserRegistered()
        ? createHomeViewController()
        : OnboardingViewController()
    }
    
    private func isUserRegistered() -> Bool {
        UserDefaults.standard.object(forKey: Constant.houseNameUserDefaultKey) != nil
    }
    
    private func createHomeViewController() async -> UIViewController {
        do {
            let homeViewModelFactory = try await DIContainer.shared.resolve(HomeViewModelFactory.self)
            let homeViewModel = homeViewModelFactory.make()
            return HomeViewController(viewModel: homeViewModel)
        } catch {
            MHLogger.error("HomeViewModelFactory 해제 실패: \(error.localizedDescription)")
            return OnboardingViewController()
        }
    }
    
    // MARK: - DIContainer Dependency Injection
    private func registerDependency() async {
        do {
            try await registerStorageDepedency()
            try await registerRepositoryDependency()
            try await registerUseCaseDependency()
            try await registerViewModelFactoryDependency()
        } catch let error as MHCoreError {
            MHLogger.error(error.description + #function)
        } catch {
            MHLogger.error(error.localizedDescription + #function)
        }
    }
    
    private func registerStorageDepedency() async throws {
        await DIContainer.shared.register(CoreDataStorage.self, object: CoreDataStorage())
        
        let coreDataStorage = try await DIContainer.shared.resolve(CoreDataStorage.self)
        await DIContainer.shared.register(
            CoreDataBookCoverStorage.self,
            object: CoreDataBookCoverStorage(coreDataStorage: coreDataStorage)
        )
        await DIContainer.shared.register(
            CoreDataBookStorage.self,
            object: CoreDataBookStorage(coreDataStorage: coreDataStorage)
        )
        await DIContainer.shared.register(
            BookCategoryStorage.self,
            object: CoreDataBookCategoryStorage(coreDataStorage: coreDataStorage)
        )
        await DIContainer.shared.register(
            BookCoverStorage.self,
            object: CoreDataBookCoverStorage(coreDataStorage: coreDataStorage)
        )
        await DIContainer.shared.register(
            BookStorage.self,
            object: CoreDataBookStorage(coreDataStorage: coreDataStorage)
        )
        await DIContainer.shared.register(
            MemorialHouseNameStorage.self,
            object: UserDefaultsMemorialHouseNameStorage()
        )
        await DIContainer.shared.register(
            MHFileManager.self,
            object: MHFileManager(directoryType: .documentDirectory)
        )
    }
    
    private func registerRepositoryDependency() async throws {
        let memorialHouseNameStorage = try await DIContainer.shared.resolve(MemorialHouseNameStorage.self)
        await DIContainer.shared.register(
            MemorialHouseNameRepository.self,
            object: LocalMemorialHouseNameRepository(storage: memorialHouseNameStorage)
        )
        
        let bookCategoryStorage = try await DIContainer.shared.resolve(BookCategoryStorage.self)
        await DIContainer.shared.register(
            BookCategoryRepository.self,
            object: LocalBookCategoryRepository(storage: bookCategoryStorage)
        )
        let bookCoverStorage = try await DIContainer.shared.resolve(BookCoverStorage.self)
        await DIContainer.shared.register(
            BookCoverRepository.self,
            object: LocalBookCoverRepository(storage: bookCoverStorage)
        )
        let bookStorage = try await DIContainer.shared.resolve(BookStorage.self)
        await DIContainer.shared.register(
            BookRepository.self,
            object: LocalBookRepository(storage: bookStorage)
        )
        let fileManager = try await DIContainer.shared.resolve(MHFileManager.self)
        await DIContainer.shared.register(
            MediaRepository.self,
            object: LocalMediaRepository(storage: fileManager)
        )
    }
    
    private func registerUseCaseDependency() async throws {
        // MARK: MemorialHouse UseCase
        let memorialHouseNameRepository = try await DIContainer.shared.resolve(MemorialHouseNameRepository.self)
        await DIContainer.shared.register(
            CreateMemorialHouseNameUseCase.self,
            object: DefaultCreateMemorialHouseNameUseCase(repository: memorialHouseNameRepository)
        )
        await DIContainer.shared.register(
            FetchMemorialHouseNameUseCase.self,
            object: DefaultFetchMemorialHouseNameUseCase(repository: memorialHouseNameRepository)
        )
        
        // MARK: Category UseCase
        let bookCategoryRepository = try await DIContainer.shared.resolve(BookCategoryRepository.self)
        await DIContainer.shared.register(
            CreateBookCategoryUseCase.self,
            object: DefaultCreateBookCategoryUseCase(repository: bookCategoryRepository)
        )
        await DIContainer.shared.register(
            FetchBookCategoriesUseCase.self,
            object: DefaultFetchBookCategoriesUseCase(repository: bookCategoryRepository)
        )
        await DIContainer.shared.register(
            UpdateBookCategoryUseCase.self,
            object: DefaultUpdateBookCategoryUseCase(repository: bookCategoryRepository)
        )
        await DIContainer.shared.register(
            DeleteBookCategoryUseCase.self,
            object: DefaultDeleteBookCategoryUseCase(repository: bookCategoryRepository)
        )
        
        // MARK: - Book UseCase
        let bookRepository = try await DIContainer.shared.resolve(BookRepository.self)
        let mediaRepository = try await DIContainer.shared.resolve(MediaRepository.self)
        await DIContainer.shared.register(
            CreateBookUseCase.self,
            object: DefaultCreateBookUseCase(repository: bookRepository,
                                             mediaRepository: mediaRepository)
        )
        await DIContainer.shared.register(
            FetchBookUseCase.self,
            object: DefaultFetchBookUseCase(repository: bookRepository)
        )
        await DIContainer.shared.register(
            UpdateBookUseCase.self,
            object: DefaultUpdateBookUseCase(repository: bookRepository)
        )
        await DIContainer.shared.register(
            DeleteBookUseCase.self,
            object: DefaultDeleteBookUseCase(repository: bookRepository)
        )
        
        // MARK: - BookCover UseCase
        let bookCoverRepository = try await DIContainer.shared.resolve(BookCoverRepository.self)
        await DIContainer.shared.register(
            CreateBookCoverUseCase.self,
            object: DefaultCreateBookCoverUseCase(repository: bookCoverRepository)
        )
        await DIContainer.shared.register(
            FetchAllBookCoverUseCase.self,
            object: DefaultFetchAllBookCoverUseCase(repository: bookCoverRepository)
        )
        await DIContainer.shared.register(
            FetchBookCoverUseCase.self,
            object: DefaultFetchBookCoverUseCase(repository: bookCoverRepository)
        )
        await DIContainer.shared.register(
            UpdateBookCoverUseCase.self,
            object: DefaultUpdateBookCoverUseCase(repository: bookCoverRepository)
        )
        await DIContainer.shared.register(
            DeleteBookCoverUseCase.self,
            object: DefaultDeleteBookCoverUseCase(repository: bookCoverRepository)
        )
        
        // MARK: - EditBook UseCase
        await DIContainer.shared.register(
            PersistentlyStoreMediaUseCase.self,
            object: DefaultPersistentlyStoreMediaUseCase(repository: mediaRepository)
        )
        await DIContainer.shared.register(
            CreateMediaUseCase.self,
            object: DefaultCreateMediaUseCase(repository: mediaRepository)
        )
        await DIContainer.shared.register(
            FetchMediaUseCase.self,
            object: DefaultFetchMediaUseCase(repository: mediaRepository)
        )
        await DIContainer.shared.register(
            DeleteMediaUseCase.self,
            object: DefaultDeleteMediaUseCase(repository: mediaRepository)
        )
        
        // MARK: - TemporaryStoreMedia UseCase
        await DIContainer.shared.register(
            TemporaryStoreMediaUseCase.self,
            object: DefaultTemporaryStoreMediaUseCase(repository: mediaRepository)
        )
        await DIContainer.shared.register(
            DeleteTemporaryMediaUseCase.self,
            object: DefaultDeleteTemporaryMediaUseCase(repository: mediaRepository)
        )
    }
    
    private func registerViewModelFactoryDependency() async throws {
        // MARK: Register ViewModel
        let createMemorialHouseNameUseCase = try await DIContainer.shared.resolve(CreateMemorialHouseNameUseCase.self)
        await DIContainer.shared.register(
            RegisterViewModelFactory.self,
            object: RegisterViewModelFactory(createMemorialHouseNameUseCase: createMemorialHouseNameUseCase)
        )
        
        // MARK: Home ViewModel
        let fetchMemorialHouseNameUseCase = try await DIContainer.shared.resolve(FetchMemorialHouseNameUseCase.self)
        let fetchAllBookCoverUseCase = try await DIContainer.shared.resolve(FetchAllBookCoverUseCase.self)
        let updateBookCoverUseCase = try await DIContainer.shared.resolve(UpdateBookCoverUseCase.self)
        let deleteBookCoverUseCase = try await DIContainer.shared.resolve(DeleteBookCoverUseCase.self)
        await DIContainer.shared.register(
            HomeViewModelFactory.self,
            object: HomeViewModelFactory(
                fetchMemorialHouseNameUseCase: fetchMemorialHouseNameUseCase,
                fetchAllBookCoverUseCase: fetchAllBookCoverUseCase,
                updateBookCoverUseCase: updateBookCoverUseCase,
                deleteBookCoverUseCase: deleteBookCoverUseCase
            )
        )
        
        // MARK: Category ViewModel
        let createBookCategoryUseCase = try await DIContainer.shared.resolve(CreateBookCategoryUseCase.self)
        let fetchBookCategoriesUseCase = try await DIContainer.shared.resolve(FetchBookCategoriesUseCase.self)
        let updateBookCategoryUseCase = try await DIContainer.shared.resolve(UpdateBookCategoryUseCase.self)
        let deleteBookCategoryUseCase = try await DIContainer.shared.resolve(DeleteBookCategoryUseCase.self)
        await DIContainer.shared.register(
            BookCategoryViewModelFactory.self,
            object: BookCategoryViewModelFactory(
                createBookCategoryUseCase: createBookCategoryUseCase,
                fetchBookCategoriesUseCase: fetchBookCategoriesUseCase,
                updateBookCategoryUseCase: updateBookCategoryUseCase,
                deleteBookCategoryUseCase: deleteBookCategoryUseCase
            )
        )
        
        // MARK: - Create BookCover ViewModel
        let createBookCoverUseCase = try await DIContainer.shared.resolve(CreateBookCoverUseCase.self)
        let createBookUseCase = try await DIContainer.shared.resolve(CreateBookUseCase.self)
        let deleteBookUseCase = try await DIContainer.shared.resolve(DeleteBookUseCase.self)
        await DIContainer.shared.register(
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
        let fetchBookCoverUseCase = try await DIContainer.shared.resolve(FetchBookCoverUseCase.self)
        await DIContainer.shared.register(
            ModifyBookCoverViewModelFactory.self,
            object: ModifyBookCoverViewModelFactory(
                fetchMemorialHouseNameUseCase: fetchMemorialHouseNameUseCase,
                fetchBookCoverUseCase: fetchBookCoverUseCase,
                updateBookCoverUseCase: updateBookCoverUseCase
            )
        )
        
        // MARK: - Book ViewModel
        let fetchBookUseCase = try await DIContainer.shared.resolve(FetchBookUseCase.self)
        await DIContainer.shared.register(
            BookViewModelFactory.self,
            object: BookViewModelFactory(fetchBookUseCase: fetchBookUseCase)
        )
        
        // MARK: - EditBook ViewModel
        let updateBookUseCase = try await DIContainer.shared.resolve(UpdateBookUseCase.self)
        let storeMediaUseCase = try await DIContainer.shared.resolve(PersistentlyStoreMediaUseCase.self)
        let deleteTemporaryMediaUseCase = try await DIContainer.shared.resolve(DeleteTemporaryMediaUseCase.self)
        let createMediaUseCase = try await DIContainer.shared.resolve(CreateMediaUseCase.self)
        let fetchMediaUseCase = try await DIContainer.shared.resolve(FetchMediaUseCase.self)
        let deleteMediaUseCase = try await DIContainer.shared.resolve(DeleteMediaUseCase.self)
        await DIContainer.shared.register(
            EditBookViewModelFactory.self,
            object: EditBookViewModelFactory(
                fetchBookUseCase: fetchBookUseCase,
                updateBookUseCase: updateBookUseCase,
                storeMediaUseCase: storeMediaUseCase,
                deleteTemporaryMediaUseCase: deleteTemporaryMediaUseCase,
                createMediaUseCase: createMediaUseCase,
                fetchMediaUseCase: fetchMediaUseCase,
                deleteMediaUseCase: deleteMediaUseCase
            )
        )
        
        // MARK: - Page ViewModel
        await DIContainer.shared.register(
            ReadPageViewModelFactory.self,
            object: ReadPageViewModelFactory(fetchMediaUseCase: fetchMediaUseCase)
        )
        
        // MARK: - CreateMediaViewModel
        let temporaryStoreMediaUseCase = try await DIContainer.shared.resolve(TemporaryStoreMediaUseCase.self)
        await DIContainer.shared.register(
            CreateAudioViewModelFactory.self,
            object: CreateAudioViewModelFactory(
                temporaryStoreMediaUseCase: temporaryStoreMediaUseCase
            )
        )
    }
}
