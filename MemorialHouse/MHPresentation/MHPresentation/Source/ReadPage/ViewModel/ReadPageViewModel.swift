import MHFoundation
import MHDomain
import MHCore
import Combine

public final class ReadPageViewModel: ViewModelType {
    enum Input {
        case viewDidLoad
        case didRequestMediaDataForData(media: MediaDescription)
    }
    
    enum Output {
        case loadPage(page: Page?)
        case mediaLoadedWithData(media: MediaDescription, data: Data)
        case error(message: String)
    }
    
    private let fetchMediaUseCase: FetchMediaUseCase
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private let bookID: UUID
    private let page: Page
    
    init(
        fetchMediaUseCase: FetchMediaUseCase,
        bookID: UUID,
        page: Page
    ) {
        self.fetchMediaUseCase = fetchMediaUseCase
        self.bookID = bookID
        self.page = page
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                self?.output.send(.loadPage(page: self?.page))
            case .didRequestMediaDataForData(let media):
                Task { await self?.loadMediaForData(media: media) }
            }
        }.store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }
    
    private func loadMediaForData(media: MediaDescription) async {
        do {
            let mediaData: Data = try await fetchMediaUseCase.execute(media: media, in: bookID)
            output.send(.mediaLoadedWithData(media: media, data: mediaData))
        } catch {
            MHLogger.error(error.localizedDescription + #function)
            output.send(.error(message: "미디어 로딩에 실패하였습니다."))
        }
    }
}
