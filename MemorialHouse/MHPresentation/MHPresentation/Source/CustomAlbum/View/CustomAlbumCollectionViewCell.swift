import UIKit

final class CustomAlbumCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    private let photoImageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
        configureConstraints()
    }
    
    // MARK: - PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoImageView.image = nil
    }
    
    // MARK: - Configure
    private func setup() {
        contentView.backgroundColor = .lightGray
    }
    
    private func configureConstraints() {
        contentView.addSubview(photoImageView)
        photoImageView.fillSuperview()
    }
    
    // MARK: - Set Cell Image
    func setPhoto(_ photo: UIImage?) async {
        photoImageView.image = photo
    }
}
