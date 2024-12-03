import MHDomain
import MHCore
import UIKit
import Combine

final class ReadPageViewController: UIViewController {
    // MARK: - Constant
    private let defaultAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.ownglyphBerry(size: 20),
        .foregroundColor: UIColor.mhTitle
    ]
    // MARK: - UI Components
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .ownglyphBerry(size: 20)
        textView.textColor = .mhTitle
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 32, bottom: 20, right: 32)
        textView.layer.borderWidth = 3
        textView.layer.borderColor = UIColor.mhTitle.cgColor
        textView.isScrollEnabled = false
        textView.isEditable = false
        
        return textView
    }()
    private var textStorage: NSTextStorage?
    
    // MARK: - Property
    private let viewModel: ReadPageViewModel
    private let input = PassthroughSubject<ReadPageViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    init(viewModel: ReadPageViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        guard let viewModelFactory = try? DIContainer.shared.resolve(ReadPageViewModelFactory.self) else { return nil }
        self.viewModel = viewModelFactory.make(bookID: UUID(), page: Page(metadata: [:], text: ""))
        
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setup()
        configureConstraints()
        input.send(.viewDidLoad)
    }
    
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
            switch event {
            case .loadPage(let page):
                guard let page else { return }
                self?.configurePage(page: page)
            case .mediaLoadedWithData(let media, let data):
                self?.mediaLoadedWithData(media: media, data: data)
            case .error(let message):
                // TODO: Alert 띄우기 ?
                MHLogger.error(message)
            }
        }.store(in: &cancellables)
    }
    
    // MARK: - Setup & Configure
    private func setup() {
        view.backgroundColor = .baseBackground
        textStorage = textView.textStorage
    }
    
    private func configureConstraints() {
        view.addSubview(textView)
        textView.setAnchor(
            top: view.topAnchor, constantTop: 10,
            leading: view.leadingAnchor, constantLeading: 10,
            bottom: view.bottomAnchor, constantBottom: 10,
            trailing: view.trailingAnchor, constantTrailing: 10
        )
    }
    
    private func configurePage(page: Page) {
        let mergedText = mergeStorageInformation(
            text: page.text,
            attachmentMetaData: page.metadata
        )
        textStorage?.setAttributedString(mergedText)
    }
    
    // MARK: - Helper
    /// Text와 Attachment 정보를 하나의 문자열로 조합합니다.
    private func mergeStorageInformation(
        text: String,
        attachmentMetaData: [Int: MediaDescription]
    ) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(string: text)
        attachmentMetaData.forEach { location, description in
            // TODO: - MediaType 별로 바꿔줘야함
            var mediaAttachment: MediaAttachment?
            switch description.type {
            case .image:
                mediaAttachment = MediaAttachment(
                    view: MHPolaroidPhotoView(),
                    description: description
                )
            default:
                break
            }
            input.send(.didRequestMediaDataForData(media: description))
            
            guard let mediaAttachment else { return }
            let range = NSRange(location: location, length: 1)
            let attachmentString = NSAttributedString(attachment: mediaAttachment)
            // Placeholder(공백) 교체
            mutableAttributedString.replaceCharacters(in: range, with: attachmentString)
        }
        
        mutableAttributedString.addAttributes(
            defaultAttributes,
            range: NSRange(
                location: 0,
                length: mutableAttributedString.length
            )
        )
        
        return mutableAttributedString
    }
    
    private func mediaLoadedWithData(media: MediaDescription, data: Data) {
        let attachment = findAttachment(by: media)
        attachment?.configure(with: data)
    }
    
    private func mediaLoadedWithURL(media: MediaDescription, url: URL) {
        let attachment = findAttachment(by: media)
        attachment?.configure(with: url)
    }
    
    /// Text에서 특정 Attachment를 찾아서 적용합니다.
    private func findAttachment(
        by media: MediaDescription
    ) -> MediaAttachment? {
        var attachment: MediaAttachment?
        guard let textStorage else { return attachment }
        textStorage.enumerateAttribute(
            .attachment,
            in: NSRange(location: 0, length: textStorage.length)
        ) { value, _, _ in
            guard let mediaAttachment = value as? MediaAttachment,
                  mediaAttachment.mediaDescription.id == media.id else { return }
            attachment = mediaAttachment
        }
        
        return attachment
    }
}
