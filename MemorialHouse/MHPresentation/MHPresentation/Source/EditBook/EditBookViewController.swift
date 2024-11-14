import UIKit

final class EditBookViewController: UIViewController {
    // MARK: - Property
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .ownglyphBerry(size: 15)
        textView.textColor = .mhTitle
        textView.tintColor = .mhTitle
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 32, bottom: 20, right: 32)
        textView.layer.borderWidth = 3
        textView.layer.borderColor = UIColor.mhTitle.cgColor
        
        return textView
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureAddSubView()
    }
    
    // MARK: - Setup & Configuration
    private func setup() {
        view.backgroundColor = .baseBackground
        hideKeyboardWhenTappedView()
    }
    private func configureAddSubView() {
        view.addSubview(textView)
        textView.setTop(anchor: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        textView.setLeading(anchor: view.leadingAnchor, constant: 20)
        textView.setTrailing(anchor: view.trailingAnchor, constant: 20)
        textView.setBottom(anchor: view.safeAreaLayoutGuide.bottomAnchor, constant: 20)
    }
}
