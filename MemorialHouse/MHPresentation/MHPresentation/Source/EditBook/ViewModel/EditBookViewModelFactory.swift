import MHDomain

public struct EditBookViewModelFactory {
    private let fetchBookUseCase: FetchBookUseCase
    private let updateBookUseCase: UpdateBookUseCase
    private let storeBookUseCase: PersistentlyStoreMediaUseCase
    private let createMediaUseCase: CreateMediaUseCase
    private let fetchMediaUseCase: FetchMediaUseCase
    private let deleteMediaUseCase: DeleteMediaUseCase
    
    public init(
        fetchBookUseCase: FetchBookUseCase,
        updateBookUseCase: UpdateBookUseCase,
        storeBookUseCase: PersistentlyStoreMediaUseCase,
        createMediaUseCase: CreateMediaUseCase,
        fetchMediaUseCase: FetchMediaUseCase,
        deleteMediaUseCase: DeleteMediaUseCase
    ) {
        self.fetchBookUseCase = fetchBookUseCase
        self.updateBookUseCase = updateBookUseCase
        self.storeBookUseCase = storeBookUseCase
        self.createMediaUseCase = createMediaUseCase
        self.fetchMediaUseCase = fetchMediaUseCase
        self.deleteMediaUseCase = deleteMediaUseCase
    }
    
    func make() -> EditBookViewModel {
        EditBookViewModel(
            fetchBookUseCase: fetchBookUseCase,
            updateBookUseCase: updateBookUseCase,
            storeBookUseCase: storeBookUseCase,
            createMediaUseCase: createMediaUseCase,
            fetchMediaUseCase: fetchMediaUseCase,
            deleteMediaUseCase: deleteMediaUseCase
        )
    }
}
