import MHDomain
import UIKit
import Combine

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
    private let input = PassthroughSubject<ReadPageViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    init(viewModel: ReadPageViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = ReadPageViewModel(page: Page(metadata: [:], text: ""))
        
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
        
        output.sink { [weak self] event in
            switch event {
            case .loadPage(let text):
                self?.textView.text = text
            }
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Setup & Configure
    private func setup() {
        view.backgroundColor = .baseBackground
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
}