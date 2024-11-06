import UIKit
import Photos

final class CustomAlbumViewController: UIViewController {
    // MARK: - Properties
    private var asset: PHFetchResult<PHAsset>?
    private let imageManager = PHCachingImageManager()
    private lazy var cellSize = (self.view.bounds.inset(by: self.view.safeAreaInsets).width - 20) / 3
    private lazy var albumCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: self.cellSize, height: self.cellSize)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    // MARK: - Initialize
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureConstraints()
    }
    
    // MARK: - Setup & Configure
    private func setup() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        asset = PHAsset.fetchAssets(with: fetchOptions)
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        albumCollectionView.register(
            CustomAlbumCollectionViewCell.self,
            forCellWithReuseIdentifier: CustomAlbumCollectionViewCell.id
        )
    }
    
    private func configureConstraints() {
        view.addSubview(albumCollectionView)
        
        NSLayoutConstraint.activate([
            albumCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            albumCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            albumCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            albumCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension CustomAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return asset?.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CustomAlbumCollectionViewCell.id,
            for: indexPath
        ) as? CustomAlbumCollectionViewCell else { return UICollectionViewCell() }
        
        guard let asset = asset?[indexPath.item] else { return cell }
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(
            for: asset,
            targetSize: CGSize(width: cellSize, height: cellSize),
            contentMode: .aspectFill, options: nil
        ) { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.setPhoto(image)
            }
        }
        
        return cell
    }
}
