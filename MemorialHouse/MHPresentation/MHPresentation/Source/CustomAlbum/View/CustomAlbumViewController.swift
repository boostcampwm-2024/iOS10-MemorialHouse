import UIKit
import Photos

final class CustomAlbumViewController: UIViewController {
    // MARK: - Properties
    private let imagePicker = UIImagePickerController()
    private lazy var albumCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let cellSize = (self.view.bounds.inset(by: self.view.safeAreaInsets).width - 6) / 3
        flowLayout.itemSize = CGSize(width: cellSize, height: cellSize)
        flowLayout.minimumLineSpacing = 3
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        return collectionView
    }()
    private let viewModel: CustomAlbumViewModel
    
    // MARK: - Initializer
    init(viewModel: CustomAlbumViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = CustomAlbumViewModel()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureConstraints()
        viewModel.action(.viewDidLoad)
    }
    
    // MARK: - Setup & Configure
    private func setup() {
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
            navigationController?.show(imagePicker, sender: nil)
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
        Task {
            if indexPath.item == 0 {
                self.openCamera()
            } else {
                guard let asset = viewModel.photoAsset?[indexPath.item - 1] else { return }
                await LocalPhotoManager.shared.requestImage(with: asset) { @Sendable [weak self] image in
                    guard let self else { return }
                    Task {
                        let editViewController = await EditPhotoViewController()
                        await editViewController.setPhoto(image: image)
                        await self.navigationController?.pushViewController(editViewController, animated: true)
                    }
                }
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
        guard let assetNum = viewModel.photoAsset?.count else { return 1 }
        return assetNum + 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CustomAlbumCollectionViewCell.identifier,
            for: indexPath
        ) as? CustomAlbumCollectionViewCell else { return UICollectionViewCell() }
        
        Task {
            if indexPath.item == 0 {
                await cell.setPhoto(.photo)
            } else {
                guard let asset = viewModel.photoAsset?[indexPath.item - 1] else { return cell }
                let cellSize = cell.bounds.size
                await LocalPhotoManager.shared.requestImage(with: asset, cellSize: cellSize) { @Sendable image in
                    Task {
                        await cell.setPhoto(image)
                    }
                }
            }
            return cell
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
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let editViewController = EditPhotoViewController()
            editViewController.setPhoto(image: image)
            self.navigationController?.pushViewController(editViewController, animated: true)
        }
    }
}
