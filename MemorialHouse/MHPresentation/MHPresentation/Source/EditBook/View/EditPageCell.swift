import UIKit

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
    private var textLayoutManager: NSTextLayoutManager?
    private var textStorage: NSTextStorage?
    private var textContainer: NSTextContainer?
    
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
        
        textLayoutManager = textView.textLayoutManager
        textStorage = textView.textStorage
        textContainer = textView.textContainer
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
}
