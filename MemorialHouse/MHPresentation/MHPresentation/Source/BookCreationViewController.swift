import UIKit

final class BookCreationViewController: UIViewController {
    // MARK: - Property
    private let bookPreviewView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        
        return view
    }()
    private let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "book")
        
        return imageView
    }()
    private let bookTitleInputView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        
        return view
    }()
    private let bookTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Book Title"
        
        return textField
    }()
    private let bookColorInputView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        
        return view
    }()
    private let bookColorPicker: [UIButton] = {
        let colorPicker = UIButton()
        
        return [colorPicker]
    }()
    private let categoryView: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        
        return view
    }()
    private let categoryPicker: UIView = {
        let categoryPicker = UIView()
        
        return categoryPicker
    }()
}
