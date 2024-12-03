import UIKit
import Combine
import MHDomain
import MHCore

final class EditPageCell: UITableViewCell {
    // MARK: - Constant
    private let defaultAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.ownglyphBerry(size: 20),
        .foregroundColor: UIColor.mhTitle
    ]
    // MARK: - Property
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .ownglyphBerry(size: 20)
        textView.textColor = .mhTitle
        textView.tintColor = .mhTitle
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 32, bottom: 20, right: 32)
        textView.layer.borderWidth = 3
        textView.layer.borderColor = UIColor.mhTitle.cgColor
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.spellCheckingType = .no
        textView.isScrollEnabled = false
        
        return textView
    }()
    private var textStorage: NSTextStorage?
    private var viewModel: EditPageViewModel?
    private let input = PassthroughSubject<EditPageViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        configureAddSubView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
        configureAddSubView()
        configureConstraints()
    }
    
    // MARK: - LifeCycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        input.send(.pageWillDisappear)
        cancellables.forEach { $0.cancel() }
        cancellables = []
        viewModel = nil
        textView.text = ""
    }
    
    // MARK: - Setup & Configuration
    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none
        
        textStorage = textView.textStorage
        textStorage?.delegate = self
        textView.delegate = self
    }
    
    private func configureAddSubView() {
        contentView.addSubview(textView)
    }
    
    private func configureConstraints() {
        textView.setAnchor(
            top: contentView.topAnchor, constantTop: 10,
            leading: contentView.leadingAnchor, constantLeading: 10,
            bottom: contentView.bottomAnchor, constantBottom: 10,
            trailing: contentView.trailingAnchor, constantTrailing: 10
        )
    }
    
    private func configureBinding() {
        let output = viewModel?.transform(input: input.eraseToAnyPublisher())
        output?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .page(let page):
                    self?.configurePage(page: page)
                case let .mediaAddedWithData(media, data):
                    self?.mediaAddedWithData(media: media, data: data)
                case let .mediaAddedWithURL(media, url):
                    self?.mediaAddedWithURL(media: media, url: url)
                case let .mediaLoadedWithData(media, data):
                    self?.mediaLoadedWithData(media: media, data: data)
                case let .mediaLoadedWithURL(media, url):
                    self?.mediaLoadedWithURL(media: media, url: url)
                case let .error(message):
                    MHLogger.error(message) // TODO: 더 좋은 처리가 필요함
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Method
    func configure(
        viewModel: EditPageViewModel
    ) {
        self.viewModel = viewModel
        configureBinding()
        input.send(.pageWillAppear)
    }
    
    // MARK: - Helper
    private func configurePage(page: Page) {
        let mergedText = mergeStorageInformation(
            text: page.text,
            attachmentMetaData: page.metadata
        )
        textStorage?.setAttributedString(mergedText)
    }
    
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
                input.send(.didRequestMediaDataForData(media: description))
            case .video:
                mediaAttachment = MediaAttachment(
                    view: MHVideoView(),
                    description: description
                )
                input.send(.didRequestMediaDataForURL(media: description))
            default:
                break
            }
            
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
    
    private func mediaAddedWithData(media: MediaDescription, data: Data) {
        var attachment: MediaAttachment?
        switch media.type {
        case .image:
            attachment = MediaAttachment(
                view: MHPolaroidPhotoView(),
                description: media
            )
        case .video:
            let view = MHVideoView()
                attachment = MediaAttachment(
                    view: view,
                    description: media
                )
        case .audio:
            // TODO: - audio 추가 필요
            attachment = MediaAttachment(
                view: MHPolaroidPhotoView(),
                description: media
            )
        default:
            break
        }
        guard let attachment else { return }
        attachment.configure(with: data)
        appendAttachment(attachment)
    }
    
    private func mediaAddedWithURL(media: MediaDescription, url: URL) {
        var attachment: MediaAttachment?
        switch media.type {
        case .image:
            attachment = MediaAttachment(
                view: MHPolaroidPhotoView(),
                description: media
            )
        case .video:
            let view = MHVideoView()
                attachment = MediaAttachment(
                    view: view,
                    description: media
                )
        case .audio:
            // TODO: - audio 추가 필요
            attachment = MediaAttachment(
                view: MHPolaroidPhotoView(),
                description: media
            )
        default:
            break
        }
        guard let attachment else { return }
        MHLogger.debug("mediaAddedWithURL: \(url)")
        attachment.configure(with: url)
        appendAttachment(attachment)
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
        textStorage
            .enumerateAttribute(
                .attachment,
                in: NSRange(location: 0, length: textStorage.length)
            ) { value, _, _ in
                guard let mediaAttachment = value as? MediaAttachment,
                   mediaAttachment.mediaDescription.id == media.id else { return }
                attachment = mediaAttachment
            }
        return attachment
    }
    
    private func appendAttachment(_ attachment: MediaAttachment) {
        guard let textStorage else { return }
        let text = NSMutableAttributedString(attachment: attachment)
        text.addAttributes(defaultAttributes,
                           range: NSRange(location: 0, length: 1))
        guard isAcceptableHeight(textStorage,
                               shouldChangeTextIn: NSRange(location: textStorage.length, length: 0),
                               replacementText: text) else { return }
        textStorage.beginEditing()
        textStorage.append(text)
        textStorage.endEditing()
    }
}

// MARK: - MediaAttachmentDataSource
extension EditPageCell: @preconcurrency MediaAttachmentDataSource {
    func mediaAttachmentDragingImage(_ mediaAttachment: MediaAttachment, about view: UIView?) -> UIImage? {
        view?.snapshotImage()
    }
}

// MARK: - UITextViewDelegate
extension EditPageCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let textStorage else { return false }
        guard let viewText = textView.text else { return false }
        let startIndex = textView.text.startIndex
        // Attachment지우기 전에 드래그해서 알려주기
        if text.isEmpty && range.length == 1
            && attachmentAt(range.location) != nil
            && textView.selectedRange.length == 0 {
            textView.selectedRange = NSRange(location: range.location, length: 1)
            return false
        }
        // 갖은 경우의 수 별로 cachedViewProvider를 nil로 변경합니다.
        // 왜냐하면, 줄바꿈을 추가했을 때, 캐시된 View가 업데이트 되어야 하기 때문입니다.
        if range.location > 0
            && viewText[viewText.index(startIndex, offsetBy: range.location-1)] == "\n"
            && text.count == 1,
           let attachment = (attachmentAt(range.location) ?? attachmentAt(min(range.location+1, viewText.count-1))) {
            attachment.cachedViewProvider = nil
        }
        if text == "\n" { // 줄바꿈을 추가할때
            if let attachment = attachmentAt(range.location) { // Attachment 앞에 줄바꿈을 추가할때
                attachment.cachedViewProvider = nil
            }
            else if let attachment = attachmentAt(range.location+1) { // Attachment 1칸 앞에 줄바꿈을 추가할때
                attachment.cachedViewProvider = nil
            }
        }
        if text.isEmpty { // 지우기할때
            if let attachment = attachmentAt(range.location+1) {  // Attachment 1칸 앞에 줄바꿈을 추가할때
                if range.location < 1 { // 첫째 줄에 도달하기 전에 지우기할때
                    attachment.cachedViewProvider = nil
                    return true
                }
                textView.selectedRange = NSRange(location: range.location, length: 0)
                return false
            }
            else if let attachment = attachmentAt(range.location+2), // Attachment 2칸 앞에 줄바꿈을 추가할때
                textView.text[textView.text.index(textView.text.startIndex, offsetBy: range.location+1)] == "\n" {
                attachment.cachedViewProvider = nil
            }
        }
        
        let attributedText = NSMutableAttributedString(
            string: text,
            attributes: defaultAttributes
        )
        return text.isEmpty
        || isAcceptableHeight(textStorage, shouldChangeTextIn: range, replacementText: attributedText)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        input.send(.didBeginEditingPage)
    }
    
    /// TextView의 높이가 적절한지 확인합니다.
    private func isAcceptableHeight(
        _ textStorage: NSTextStorage,
        shouldChangeTextIn range: NSRange,
        replacementText attributedText: NSAttributedString
    ) -> Bool {
        let updatedText = NSMutableAttributedString(attributedString: textStorage)
        let horizontalInset = textView.textContainerInset.left + textView.textContainerInset.right
        let verticalInset = textView.textContainerInset.top + textView.textContainerInset.bottom
        let textViewWidth = textView.bounds.width - horizontalInset
        let textViewHight = textView.bounds.height - verticalInset
        let temporaryTextView = UITextView(
            frame: CGRect(x: 0, y: 0, width: textViewWidth, height: .greatestFiniteMagnitude)
        )
        
        updatedText.replaceCharacters(in: range, with: attributedText)
        temporaryTextView.attributedText = updatedText
        temporaryTextView.sizeToFit()
        
        return temporaryTextView.contentSize.height <= textViewHight
    }
}

// MARK: - NSTextStorageDelegate
extension EditPageCell: @preconcurrency NSTextStorageDelegate {
    func textStorage(
        _ textStorage: NSTextStorage,
        willProcessEditing editedMask: NSTextStorage.EditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        // 입력하는 곳 앞에 Attachment가 있을 때, 줄바꿈을 추가합니다.
        guard delta > 0 else { return }
        lineBreakForAttachment()
    }
    
    func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: NSTextStorage.EditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        input.send(.didEditPage(attributedText: textStorage))
    }
    
    // 그곳에 Attachment가 있는지 확인합니다.
    private func attachmentAt(_ index: Int) -> MediaAttachment? {
        guard let textStorage else { return nil }
        guard index >= 0 && index < textStorage.length else { return nil }
        return textStorage.attributes(at: index, effectiveRange: nil)[.attachment] as? MediaAttachment
    }
    
    private func lineBreakForAttachment() {
        guard let currentString = textStorage?.string else { return }
        let startIndex = currentString.startIndex
        let range = NSRange(location: 0, length: currentString.count)
        let newLine = NSAttributedString(string: "\n", attributes: defaultAttributes)
        textStorage?.enumerateAttribute(.attachment, in: range, using: { value, range, _ in
            guard let attachment = value as? MediaAttachment else { return }
            let location = range.location
            // Attachment 앞에 줄바꿈이 없을 때, 줄바꿈을 추가합니다.
            if location > 0 {
                if currentString[currentString.index(startIndex, offsetBy: location-1)] != "\n" {
                    textStorage?.insert(newLine, at: location)
                    attachment.cachedViewProvider = nil
                }
            }
            // Attachment 뒤에 줄바꿈이 없을 때, 줄바꿈을 추가합니다.
            let nextLocation = location + range.length
            if nextLocation < currentString.count
                && currentString[currentString.index(startIndex, offsetBy: nextLocation)] != "\n" {
                textStorage?.insert(newLine, at: nextLocation)
                guard nextLocation+1 < textStorage?.length ?? -1 else { return }
                textView.selectedRange = NSRange(location: nextLocation+1, length: 0)
            }
        })
    }
}
