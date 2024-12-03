import MHFoundation
import MHDomain
import MHCore
import Combine

public final class ReadPageViewModel: ViewModelType {
    enum Input {
        case viewDidLoad
        case didRequestMediaDataForData(media: MediaDescription)
        case didRequestMediaDataForURL(media: MediaDescription)
    }
    
    enum Output {
        case loadPage(page: Page?)
        case mediaLoadedWithData(media: MediaDescription, data: Data)
        case mediaLoadedWithURL(media: MediaDescription, url: URL)
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
            case .didRequestMediaDataForURL(let media):
                Task { await self?.loadMediaForURL(media: media) }
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
    
    private func loadMediaForURL(media: MediaDescription) async {
        do {
            let mediaURL: URL = try await fetchMediaUseCase.execute(media: media, in: bookID)
            output.send(.mediaLoadedWithURL(media: media, url: mediaURL))
        } catch {
            output.send(.error(message: "미디어 로딩에 실패하였습니다."))
            MHLogger.error(error.localizedDescription + #function)
        }
    }
}
