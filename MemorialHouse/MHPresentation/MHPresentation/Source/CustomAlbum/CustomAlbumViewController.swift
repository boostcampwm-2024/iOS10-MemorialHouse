import UIKit
import Photos

final class CustomAlbumViewController: UIViewController {
    // MARK: - Properties
    private var imageAsset: PHFetchResult<PHAsset>?
    private let imageManager = PHCachingImageManager()
    private let imagePicker = UIImagePickerController()
    
    private lazy var albumCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let cellSize = (self.view.bounds.inset(by: self.view.safeAreaInsets).width - 10) / 3
        flowLayout.itemSize = CGSize(width: cellSize, height: cellSize)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        return collectionView
    }()
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureConstraints()
    }
    
    // MARK: - Setup & Configure
    private func setup() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        imageAsset = PHAsset.fetchAssets(with: fetchOptions)
        imagePicker.delegate = self
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        albumCollectionView.register(
            CustomAlbumCollectionViewCell.self,
            forCellWithReuseIdentifier: CustomAlbumCollectionViewCell.identifier
        )
    }
    
    private func configureConstraints() {
        view.addSubview(albumCollectionView)
        albumCollectionView.fillSuperview()
    }
    
    // MARK: - Open Camera
    private func openCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            imagePicker.sourceType = .camera
            navigationController?.pushViewController(imagePicker, animated: true)
        } else {
            // TODO: - 카메라 접근 권한 Alert
        }
    }
}

// MARK: - UICollectionViewDelegate
extension CustomAlbumViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if indexPath.item == 0 {
            self.openCamera()
        } else {
            guard let asset = self.imageAsset?[indexPath.item - 1] else { return }
            imageManager.requestImage(
                for: asset,
                targetSize: .zero,
                contentMode: .default,
                options: nil
            ) { image, _ in
                // TODO: - 이미지 편집 뷰 로 이동
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CustomAlbumViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let imageAsset else { return 1 }
        return imageAsset.count + 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CustomAlbumCollectionViewCell.identifier,
            for: indexPath
        ) as? CustomAlbumCollectionViewCell else { return UICollectionViewCell() }
        
        if indexPath.item == 0 {
            cell.setPhoto(.photo)
        } else {
            guard let asset = imageAsset?[indexPath.item - 1] else { return cell }
            let cellSize = cell.bounds.size
            imageManager.requestImage(
                for: asset,
                targetSize: cellSize,
                contentMode: .aspectFill,
                options: nil
            ) { image, _ in
                cell.setPhoto(image)
            }
        }
        
        return cell
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension CustomAlbumViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // TODO: - 이미지 편집 뷰로 이동
        }
        dismiss(animated: true, completion: nil)
    }
}
