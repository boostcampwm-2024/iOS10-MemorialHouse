import UIKit

final class BookCreationViewController: UIViewController {
    // MARK: - Property
    private let bookPreviewView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        
        view.layer.cornerRadius = 17
        view.layer.borderWidth = 1.5
        view.layer.borderColor = #colorLiteral(red: 0.7619946599, green: 0.2259112597, blue: 0.1530924141, alpha: 1)
        view.clipsToBounds = true
        
        return view
    }()
    private let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .pinkBook)
        
        return imageView
    }()
    private let bookTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Book Title"
        
        let leftView = UILabel(style: .default)
        leftView.text = "책 제목 | "
        textField.leftView = leftView
        
        textField.layer.cornerRadius = 17
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = #colorLiteral(red: 0.7619946599, green: 0.2259112597, blue: 0.1530924141, alpha: 1)
        textField.clipsToBounds = true
        
        return textField
    }()
    private let bookColorInputView: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 17
        view.layer.borderWidth = 1.5
        view.layer.borderColor = #colorLiteral(red: 0.7619946599, green: 0.2259112597, blue: 0.1530924141, alpha: 1)
        view.clipsToBounds = true
        
        return view
    }()
    private let bookColorButtons: [UIButton] = zip(
        ["분홍", "초록", "파랑", "주황", "베이지"],
        [UIColor.mhPink, .mhGreen, .mhBlue, .mhOrange, .mhBeige]
    ).map { title, color in
        let button = UIButton(frame: CGRect(origin: .zero, size: .init(width: 30, height: 66)))
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 30
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.clipsToBounds = true
        return button
    }
    private let categorySelectionButton: UIButton = {
        let button = UIButton()
        button.setTitle("카테고리 선택 | 없음", for: .normal)
        
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1.5
        button.layer.borderColor = #colorLiteral(red: 0.7619946599, green: 0.2259112597, blue: 0.1530924141, alpha: 1)
        button.clipsToBounds = true
        
        return button
    }()
    private let imageSelectionButton: UIButton = {
        let button = UIButton()
        button.setTitle("사진 선택", for: .normal)
        
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1.5
        button.layer.borderColor = #colorLiteral(red: 0.7619946599, green: 0.2259112597, blue: 0.1530924141, alpha: 1)
        button.clipsToBounds = true
        
        return button
    }()
    
    
    
}
