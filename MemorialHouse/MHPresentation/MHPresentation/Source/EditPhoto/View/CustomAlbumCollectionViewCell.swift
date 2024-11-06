import UIKit

final class CustomAlbumCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let id = "CustomAlbumCollectionViewCell"
    private let photoImageView = UIImageView(image: nil)
    var representedAssetIdentifier: String?
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoImageView.image = nil
    }
    
    // MARK: - Setup & Configure
    private func setup() {
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureConstraints() {
        contentView.addSubview(photoImageView)
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Set Cell Image
    func setPhoto(_ photo: UIImage?) {
        photoImageView.image = photo
    }
}
