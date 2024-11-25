import UIKit
import MHCore

final class EditPageCell: UITableViewCell {
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
    
    // MARK: - Setup & Configuration
    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none
        
        textStorage = textView.textStorage
    }
    private func configureAddSubView() {
        addSubview(textView)
    }
    private func configureConstraints() {
        textView.setAnchor(
            top: topAnchor, constantTop: 10,
            leading: leadingAnchor, constantLeading: 10,
            bottom: bottomAnchor, constantBottom: 10,
            trailing: trailingAnchor, constantTrailing: 10
        )
    }
    
    // MARK: - TouchEvent
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.becomeFirstResponder()
        
        super.touchesBegan(touches, with: event)
    }
    
    // MARK: - Method
    /// Storage에서 Text와 Attachment 정보를 추출해냅니다.
    private func separateStorageInformation(_ textStorage: NSTextStorage) -> (NSAttributedString, [String: Any]) {
        var attachmentMetadata: [String: Any] = [:]
        let mutableAttributedString = NSMutableAttributedString(attributedString: textStorage)
        
        textStorage.enumerateAttribute(.attachment, in: NSRange(location: 0, length: textStorage.length)) { value, range, _ in
            if let mediaAttachment = value as? MediaAttachment,
               let url = mediaAttachment.sourcePath {
                // 위치와 URL 저장
                attachmentMetadata[String(range.location)] = url.absoluteString
                // Placeholder로 텍스트 대체
                mutableAttributedString.replaceCharacters(in: range, with: " ")
            }
        }
        
        return (mutableAttributedString, attachmentMetadata)
    }
    /// Text와 Attachment 정보를 하나의 문자열로 조합합니다.
    private func mergeStorageInformation(text savedAttributedString: NSAttributedString, attachmentMetaData: [String: Any]) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: savedAttributedString)
        
        attachmentMetaData
            .map { (Int($0.key) ?? 0, $0.value as? String ?? "") }
            .forEach { location, urlString in
                let range = NSRange(location: location, length: 1)
                let mediaAttachment = MediaAttachment()
                mediaAttachment.sourcePath = URL(string: urlString)
                let attachmentString = NSAttributedString(attachment: mediaAttachment)
                
                // Placeholder(공백) 교체
                mutableAttributedString.replaceCharacters(in: range, with: attachmentString)
            }
        
        return mutableAttributedString
    }
    private func saveTextWithAttachments() {
        guard let textStorage = textStorage else { return }
        
        let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        let (savedText, metadata) = separateStorageInformation(textStorage)
        
        do {
            let fileURL = documentDirectory.appendingPathComponent("textWithAttachments.rtf")
            let rtfData = try savedText.data(
                from: NSRange(location: 0, length: savedText.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
            )
            try rtfData.write(to: fileURL)
            MHLogger.debug("Text with attachments saved to \(fileURL)")
        } catch {
            MHLogger.error("Error saving text with attachments: \(error)")
        }
        
        do {
            let metadataFileURL = documentDirectory.appendingPathComponent("attachmentMetadata.json")
            let metadataData = try JSONSerialization.data(withJSONObject: metadata, options: [])
            try metadataData.write(to: metadataFileURL)
            MHLogger.debug("Attachment metadata saved to \(metadataFileURL)")
        } catch {
            MHLogger.error("Error saving attachment metadata: \(error)")
        }
    }
    private func loadTextWithAttachments() {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent("textWithAttachments.rtf")
        do {
            let rtfData = try Data(contentsOf: fileURL)
            let savedText = try NSAttributedString(
                data: rtfData,
                options: [.documentType: NSAttributedString.DocumentType.rtf],
                documentAttributes: nil
            )
            let metadataFileURL = documentDirectory.appendingPathComponent("attachmentMetadata.json")
            let metadataData = try Data(contentsOf: metadataFileURL)
            let metadata = try JSONSerialization.jsonObject(with: metadataData) as! [String: Any]
            // 커스텀 NSTextAttachment로 변환
            let restoredText = mergeStorageInformation(text: savedText, attachmentMetaData: metadata)
            textStorage?.setAttributedString(restoredText)
            MHLogger.debug("Text with attachments loaded from \(fileURL)")
        } catch {
            MHLogger.error("Error loading text with attachments: \(error)")
        }
    }
    
    private func isAcceptableHight(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText attributedText: NSAttributedString) -> Bool {
        let updatedText = NSMutableAttributedString(attributedString: textView.attributedText)
        let textViewWidth = textView.bounds.width
        let temporaryTextView = UITextView(
            frame: CGRect(x: 0, y: 0, width: textViewWidth, height: .greatestFiniteMagnitude)
        )
        updatedText.append(attributedText)
        updatedText.replaceCharacters(in: range, with: attributedText)
        temporaryTextView.attributedText = updatedText
        temporaryTextView.sizeToFit()
        
        return temporaryTextView.contentSize.height <= textView.bounds.height
                || attributedText.string.isEmpty
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
        return isAcceptableHight(textView, shouldChangeTextIn: range, replacementText: .init(string: text))
    }
}
