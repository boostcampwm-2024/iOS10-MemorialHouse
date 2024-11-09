import UIKit

public final class HomeViewController: UIViewController {
    // MARK: - Property
    private let navigationBar = MHNavigationBar(title: "효준")
    
    // MARK: - Initializer
    public init() {
        for family in UIFont.familyNames {
            print("Font Family: \(family)")
            for fontName in UIFont.fontNames(forFamilyName: family) {
                print("   Font Name: \(fontName)")
            }
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - View LifeCycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureConstraints()
    }
    
    private func setup() {
        view.backgroundColor = .baseBackground
        view.addSubview(navigationBar)
    }
    
    private func configureConstraints() {
        navigationBar.setTop(anchor: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        navigationBar.setLeading(anchor: view.leadingAnchor, constant: 24)
        navigationBar.setTrailing(anchor: view.trailingAnchor, constant: 24)
    }
}
