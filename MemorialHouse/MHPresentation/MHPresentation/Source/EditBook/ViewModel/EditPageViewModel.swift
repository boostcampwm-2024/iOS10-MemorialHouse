import MHFoundation
@preconcurrency import Combine
import MHDomain
import MHCore

final class EditPageViewModel: ViewModelType {
    // MARK: - Type
    enum Input {
        case pageWillAppear
        case pageWillDisappear(attributedText: NSAttributedString)
        case didRequestMediaDataForData(media: MediaDescription)
        case didRequestMediaDataForURL(media: MediaDescription)
    }
    enum Output {
        case page(page: Page)
        case mediaAddedWithData(media: MediaDescription, data: Data)
        case mediaAddedWithURL(media: MediaDescription, url: URL)
        case mediaLoadedWithData(media: MediaDescription, data: Data)
        case mediaLoadedWithURL(media: MediaDescription, url: URL)
    }
    
    // MARK: - Property
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let createMediaUseCase: CreateMediaUseCase
    private let fetchMediaUseCase: FetchMediaUseCase
    private let deleteMediaUseCase: DeleteMediaUseCase
    private var bookID: UUID
    private var page: Page
    
    // MARK: - Initializer
    init(
        createMediaUseCase: CreateMediaUseCase,
        fetchMediaUseCase: FetchMediaUseCase,
        deleteMediaUseCase: DeleteMediaUseCase,
        bookID: UUID,
        page: Page
    ) {
        self.createMediaUseCase = createMediaUseCase
        self.fetchMediaUseCase = fetchMediaUseCase
        self.deleteMediaUseCase = deleteMediaUseCase
        self.bookID = bookID
        self.page = page
    }
    
    // MARK: - Binding Method
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .pageWillAppear:
                self?.pageWillAppear()
            case .pageWillDisappear(let attributedText):
                self?.pageWillDisappear(text: attributedText)
            case .didRequestMediaDataForData(let media):
                Task { await self?.loadMediaForData(media: media) }
            case .didRequestMediaDataForURL(let media):
                Task { await self?.loadMediaForURL(media: media) }
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    private func pageWillAppear() {
        output.send(.page(page: page))
    }
    private func pageWillDisappear(text: NSAttributedString) {
        let page = converTextToPage(text: text)
        self.page = page
    }
    private func loadMediaForData(media: MediaDescription) async {
        // TODO: - Loading실패시 로딩실패 처리
        guard let mediaData: Data = try? await fetchMediaUseCase.execute(media: media, in: bookID) else { return }
        output.send(.mediaLoadedWithData(media: media, data: mediaData))
    }
    private func loadMediaForURL(media: MediaDescription) async {
        // TODO: - Loading실패시 로딩실패 처리
        guard let mediaURL: URL = try? await fetchMediaUseCase.execute(media: media, in: bookID) else { return }
        output.send(.mediaLoadedWithURL(media: media, url: mediaURL))
    }
    
    // MARK: - Method
    func addMedia(media: MediaDescription, data: Data) {
        output.send(.mediaAddedWithData(media: media, data: data))
    }
    func addMedia(media: MediaDescription, url: URL) {
        output.send(.mediaAddedWithURL(media: media, url: url))
    }
    
    // MARK: - Helper
    private func converTextToPage(text: NSAttributedString) -> Page {
        let (savedText, metadata) = separateStorageInformation(text)
        let newPage = Page(
            id: page.id,
            metadata: metadata,
            text: savedText
        )
        return newPage
    }
    /// NSAttributedString에서 Text와 Attachment 정보를 추출해냅니다.
    private func separateStorageInformation(
        _ text: NSAttributedString
    ) -> (String, [Int: MediaDescription]) {
        var metaData = [Int: MediaDescription]()
        let mutableAttributedString = NSMutableAttributedString(attributedString: text)
        
        text.enumerateAttribute(.attachment, in: NSRange(location: 0, length: text.length)) { value, range, _ in
            if let mediaAttachment = value as? MediaAttachment {
                metaData[range.location] = mediaAttachment.mediaDescription
                // Placeholder로 텍스트 대체
                mutableAttributedString.replaceCharacters(in: range, with: " ")
            }
        }
        return (mutableAttributedString.string, metaData)
    }
}