import UIKit

final class ReadPageViewController: UIViewController {
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
    private var textLayoutManager: NSTextLayoutManager?
    private var textStorage: NSTextStorage?
    private var textContainer: NSTextContainer?
    
    // MARK: - Property
    private let viewModel: ReadPageViewModel
    
    // MARK: - Initialize
    init(viewModel: ReadPageViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = ReadPageViewModel(index: 0)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureConstraints()
    }
    
    // MARK: - Setup & Configure
    private func setup() {
        view.backgroundColor = .baseBackground
        textView.text = String(viewModel.index)
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
    
    func getPageIndex() -> Int {
        return viewModel.index
    }
}
