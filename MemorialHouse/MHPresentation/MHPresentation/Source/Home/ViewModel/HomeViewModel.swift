import Combine
import MHCore
import MHDomain
import Foundation

public final class HomeViewModel: ViewModelType {
    public enum Input {
        case loadAllBookCovers
        case selectedCategory(category: String)
        case dragAndDropBookCover(currentIndex: Int, destinationIndex: Int)
        case likeButtonTapped(bookId: UUID)
        case deleteBookCover(bookId: UUID)
    }
    
    public enum Output: Equatable {
        case fetchedMemorialHouseName
        case reloadData
        case fetchedFailure(String)
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private let fetchMemorialHouseNameUseCase: FetchMemorialHouseNameUseCase
    private let fetchAllBookCoverUseCase: FetchAllBookCoverUseCase
    private let updateBookCoverUseCase: UpdateBookCoverUseCase
    private let deleteBookCoverUseCase: DeleteBookCoverUseCase
    private var cancellables = Set<AnyCancellable>()
    private(set) var houseName = ""
    private(set) var bookCovers = [BookCover]()
    private(set) var currentBookCovers = [BookCover]()
    
    public init(
        fetchMemorialHouseUseCase: FetchMemorialHouseNameUseCase,
        fetchAllBookCoverUseCase: FetchAllBookCoverUseCase,
        updateBookCoverUseCase: UpdateBookCoverUseCase,
        deleteBookCoverUseCase: DeleteBookCoverUseCase
    ) {
        self.fetchMemorialHouseNameUseCase = fetchMemorialHouseUseCase
        self.fetchAllBookCoverUseCase = fetchAllBookCoverUseCase
        self.updateBookCoverUseCase = updateBookCoverUseCase
        self.deleteBookCoverUseCase = deleteBookCoverUseCase
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .loadAllBookCovers:
                Task {
                    self?.fetchMemorialHouse()
                    self?.fetchAllBookCover()
                }
            case .selectedCategory(let category):
                self?.filterBooks(by: category)
            case .dragAndDropBookCover(let currentIndex, let destinationIndex):
                self?.dragAndDropBookCover(from: currentIndex, to: destinationIndex)
            case .likeButtonTapped(let bookId):
                Task { self?.likeButtonTapped(bookId: bookId) }
            case .deleteBookCover(let bookId):
                Task { self?.deleteBookCover(bookId: bookId) }
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func fetchMemorialHouse() {
        do {
            let memorialHouseName = try fetchMemorialHouseNameUseCase.execute()
            houseName = memorialHouseName
            output.send(.fetchedMemorialHouseName)
        } catch {
            output.send(.fetchedFailure("MemorialHouseName 로드 중 에러가 발생했습니다."))
            MHLogger.error("MemorialHouseName 로드 에러 발생: \(error.localizedDescription)")
        }
    }
    
    private func fetchAllBookCover() {
        do {
            let bookCovers = try fetchAllBookCoverUseCase.execute()
            self.bookCovers = bookCovers
            self.currentBookCovers = bookCovers
            output.send(.reloadData)
        } catch {
            output.send(.fetchedFailure("책들을 불러오는 중에 에러가 발생했습니다."))
            MHLogger.error("책들을 불러오는 중에 에러 발생: \(error.localizedDescription)")
        }
    }
    
    private func likeButtonTapped(bookId: UUID) {
        guard
            let bookCoverIndex = bookCovers.firstIndex(where: { $0.id == bookId }),
            let currentBookCoverindex = currentBookCovers.firstIndex(where: { $0.id == bookId })
        else { return }
        
        let currentBookCover = currentBookCovers[currentBookCoverindex]
        let bookCover = BookCover(
            id: currentBookCover.id,
            order: currentBookCover.order,
            title: currentBookCover.title,
            imageData: currentBookCover.imageData,
            color: currentBookCover.color,
            category: currentBookCover.category,
            favorite: !currentBookCover.favorite
        )
        
        do {
            try updateBookCoverUseCase.execute(id: bookId, with: bookCover)
            bookCovers[bookCoverIndex] = bookCover
            currentBookCovers[currentBookCoverindex] = bookCover
        } catch {
            output.send(.fetchedFailure("좋아요에 실패했습니다."))
            MHLogger.error("좋아요 에러 발생: \(error.localizedDescription)")
        }
    }
    
    private func deleteBookCover(bookId: UUID) {
        do {
            try deleteBookCoverUseCase.execute(id: bookId)
            guard
                let bookCoverIndex = bookCovers.firstIndex(where: { $0.id == bookId }),
                let currentBookCoverIndex = currentBookCovers.firstIndex(where: { $0.id == bookId })
            else { return }
            
            bookCovers.remove(at: bookCoverIndex)
            currentBookCovers.remove(at: currentBookCoverIndex)
            output.send(.reloadData)
        } catch {
            MHLogger.error("삭제 에러 발생: \(error.localizedDescription)")
            output.send(.fetchedFailure("삭제에 실패했습니다."))
        }
    }
    
    private func filterBooks(by category: String) {
        switch category {
        case "전체":
            currentBookCovers = bookCovers
        case "즐겨찾기":
            currentBookCovers = bookCovers.filter { $0.favorite }
        default:
            currentBookCovers = bookCovers.filter { $0.category == category }
        }
        
        output.send(.reloadData)
    }
    
    private func dragAndDropBookCover(from currentIndex: Int, to destinationIndex: Int) {
        let currentBookCover = currentBookCovers[currentIndex]
        let targetBookCover = currentBookCovers[destinationIndex]
        bookCovers.remove(at: currentBookCover.order)
        bookCovers.insert(currentBookCover, at: targetBookCover.order)
        currentBookCovers.remove(at: currentIndex)
        currentBookCovers.insert(currentBookCover, at: destinationIndex)
        output.send(.reloadData)
    }
}
