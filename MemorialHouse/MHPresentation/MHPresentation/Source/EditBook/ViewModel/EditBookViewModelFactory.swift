import MHFoundation
import MHDomain

public struct EditBookViewModelFactory {
    private let fetchBookUseCase: FetchBookUseCase
    private let updateBookUseCase: UpdateBookUseCase
    private let storeMediaUseCase: PersistentlyStoreMediaUseCase
    private let createMediaUseCase: CreateMediaUseCase
    private let fetchMediaUseCase: FetchMediaUseCase
    private let deleteMediaUseCase: DeleteMediaUseCase
    
    public init(
        fetchBookUseCase: FetchBookUseCase,
        updateBookUseCase: UpdateBookUseCase,
        storeMediaUseCase: PersistentlyStoreMediaUseCase,
        createMediaUseCase: CreateMediaUseCase,
        fetchMediaUseCase: FetchMediaUseCase,
        deleteMediaUseCase: DeleteMediaUseCase
    ) {
        self.fetchBookUseCase = fetchBookUseCase
        self.updateBookUseCase = updateBookUseCase
        self.storeMediaUseCase = storeMediaUseCase
        self.createMediaUseCase = createMediaUseCase
        self.fetchMediaUseCase = fetchMediaUseCase
        self.deleteMediaUseCase = deleteMediaUseCase
    }
    
    func make(bookID: UUID) -> EditBookViewModel {
        EditBookViewModel(
            fetchBookUseCase: fetchBookUseCase,
            updateBookUseCase: updateBookUseCase,
            storeMediaUseCase: storeMediaUseCase,
            createMediaUseCase: createMediaUseCase,
            fetchMediaUseCase: fetchMediaUseCase,
            deleteMediaUseCase: deleteMediaUseCase,
            bookID: bookID
        )
    }
}
