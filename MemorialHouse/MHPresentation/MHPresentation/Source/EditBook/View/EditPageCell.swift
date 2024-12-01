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
                    MHLogger.error(message) // 더 좋은 처리가 필요함
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Method
    func configure(viewModel: EditPageViewModel) {
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
    private func mediaAddedWithData(media: MediaDescription, data: Data) {
        let attachment = MediaAttachment(
            view: MHPolaroidPhotoView(), // TODO: - 수정 필요
            description: media
        )
        attachment.configure(with: data)
        let text = NSMutableAttributedString(attachment: attachment)
        text.addAttributes(defaultAttributes,
                           range: NSRange(location: 0, length: 1))
        textStorage?.append(text)
    }
    private func mediaAddedWithURL(media: MediaDescription, url: URL) {
        let attachment = MediaAttachment(
            view: MHPolaroidPhotoView(),// TODO: - 수정 필요
            description: media
        )
        attachment.configure(with: url)
        let text = NSMutableAttributedString(attachment: attachment)
        text.addAttributes(defaultAttributes,
                           range: NSRange(location: 0, length: 1))
        textStorage?.append(text)
    }
    private func mediaLoadedWithData(media: MediaDescription, data: Data) {
        let attachment = findAttachment(by: media)
        attachment?.configure(with: data)
    }
    private func mediaLoadedWithURL(media: MediaDescription, url: URL) {
        let attachment = findAttachment(by: media)
        attachment?.configure(with: url)
    }
    private func saveContents() {
        guard let textStorage else { return }
        
        input.send(.didEditPage(attributedText: textStorage))
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
            if let mediaAttachment = value as? MediaAttachment,
               mediaAttachment.mediaDescription.id == media.id {
                attachment = mediaAttachment
                return
            }
        }
        return attachment
    }
    /// Text와 Attachment 정보를 하나의 문자열로 조합합니다.
    private func mergeStorageInformation(
        text: String,
        attachmentMetaData: [Int: MediaDescription]
    ) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(string: text)
        attachmentMetaData.forEach { location, description in
            let range = NSRange(location: location, length: 1)
            let mediaAttachment = MediaAttachment(
                view: MHPolaroidPhotoView(), // TODO: - 이거 바꿔줘야함...
                description: description
            )
            input.send(.didRequestMediaDataForData(media: description))
            let attachmentString = NSAttributedString(attachment: mediaAttachment)
            // Placeholder(공백) 교체
            mutableAttributedString.replaceCharacters(in: range, with: attachmentString)
        }
        
        mutableAttributedString.addAttributes(defaultAttributes,
                                              range: NSRange(location: 0, length: mutableAttributedString.length))
        
        return mutableAttributedString
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
        let attributedText = NSAttributedString(
            string: text,
            attributes: defaultAttributes
        )
        return text.isEmpty
        || isAcceptableHeight(textStorage, shouldChangeTextIn: range, replacementText: attributedText)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        input.send(.didBeginEditingPage)
    }
}

// MARK: - NSTextStorageDelegate
extension EditPageCell: @preconcurrency NSTextStorageDelegate {
    func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: NSTextStorage.EditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        let text = textStorage.attributedSubstring(from: editedRange)
        if !isAcceptableHeight(textStorage, shouldChangeTextIn: editedRange, replacementText: text) {
            // TODO: - 좀더 우아하게 처리하기? 미리 알려주는 로직으로... 개선필요
            textStorage.deleteCharacters(in: editedRange)
        }
        saveContents()
    }
}
