import UIKit

final class OnboardingPageViewController: UIViewController {
    private let imageView = UIImageView()
    
    // MARK: - Initializer
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        imageView.image = .onboardingOne
        imageView.contentMode = .scaleAspectFill
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAddSubview()
    }
    
    // MARK: - Setup & Configuration
    private func configureAddSubview() {
        view.addSubview(imageView)
        imageView.fillSuperview()
    }
}
