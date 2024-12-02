import Combine
import Photos
import MHCore
import MHDomain
import MHFoundation

final class CreateBookViewModel: ViewModelType {
    enum Input {
        case createBook
        case updateTextField(text: String)
    }
    
    enum Output {
        case createdBook
        case updatedBookCover
    }
    
    var bookTitle: String = ""
    var bookCategory: String = ""
    var previousColorNumber: Int = -1
    var currentColorNumber: Int = 0
    var coverPicture: PHAsset?
    var currentColor: BookColor {
        switch currentColorNumber {
        case 0: .pink
        case 1: .green
        case 2: .blue
        case 3: .orange
        case 4: .beige
        default: .blue
        }
    }
    private let createBookCoverUseCase: CreateBookCoverUseCase
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    let houseName: String
    
    init(
        createBookCoverUseCase: CreateBookCoverUseCase,
        houseName: String
    ) {
        self.createBookCoverUseCase = createBookCoverUseCase
        self.houseName = houseName
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .createBook:
                Task { await self?.createBookInCoreData() }
            case .updateTextField(let text):
                self?.vaildateBookTitle(text: text)
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func createBookInCoreData() async {
        let bookCover = BookCover(
            order: 0,
            title: bookTitle,
            imageURL: nil,
            color: currentColor,
            category: bookCategory,
            favorite: false
        )
        do {
            try await createBookCoverUseCase.execute(with: bookCover)
            output.send(.createdBook)
        } catch {
            MHLogger.error("Create BookCover 실패: \(error.localizedDescription)")
        }
    }
    
    private func vaildateBookTitle(text: String) {
        bookTitle = text
    }
}
