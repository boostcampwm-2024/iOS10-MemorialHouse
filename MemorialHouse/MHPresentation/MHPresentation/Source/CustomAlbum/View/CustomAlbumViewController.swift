import UIKit
import Photos
import Combine

final class CustomAlbumViewController: UIViewController {
    // MARK: - Properties
    private lazy var albumCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let cellSize = (self.view.bounds.inset(by: self.view.safeAreaInsets).width - 6) / 3
        flowLayout.itemSize = CGSize(width: cellSize, height: cellSize)
        flowLayout.minimumLineSpacing = 3
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    private let viewModel: CustomAlbumViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(viewModel: CustomAlbumViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = CustomAlbumViewModel()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setup()
        configureConstraints()
        viewModel.action(.viewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavagationBar()
    }
    
    // MARK: - Binding
    private func bind() {
        viewModel.changedAssetsOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] changes in
                self?.albumCollectionView.performBatchUpdates {
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        self?.albumCollectionView.insertItems(at: inserted.map({ IndexPath(item: $0 + 1, section: 0) }))
                    }
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        self?.albumCollectionView.deleteItems(at: removed.map({ IndexPath(item: $0 + 1, section: 0) }))
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Setup & Configure
    private func setup() {
        view.backgroundColor = .baseBackground
        PHPhotoLibrary.shared().register(self)
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
    
    private func configureNavagationBar() {
        // TODO: - 추후 삭제 필요
        self.navigationController?.navigationBar.isHidden = false
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .baseBackground
        navigationBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.ownglyphBerry(size: 17),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.compactAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.title = "사진 선택"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.ownglyphBerry(size: 17),
            NSAttributedString.Key.foregroundColor: UIColor.mhTitle]
        let closeAction = UIAction { [weak self] _ in
            guard let self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        let leftBarButton = UIBarButtonItem(title: "닫기", primaryAction: closeAction)
        leftBarButton.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.ownglyphBerry(size: 17),
             NSAttributedString.Key.foregroundColor: UIColor.mhTitle],
            for: .normal
        )
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    // MARK: - Camera
    private func checkCameraAuthorization() {
        let authorization = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authorization {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { @Sendable granted in
                if granted {
                    Task { [weak self] in
                        await self?.openCamera()
                    }
                } else {
                    // TODO: 카메라 권한 설정 페이지로 이동
                    print("카메라 권한 거부")
                }
            }
        case .authorized:
            openCamera()
        case .restricted, .denied:
            // TODO: 카메라 권한 설정 페이지로 이동
            print("카메라 권한 거부")
        @unknown default:
            fatalError("Unknown case")
        }
    }
    
    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            navigationController?.show(imagePicker, sender: nil)
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
            self.checkCameraAuthorization()
        } else {
            guard let asset = viewModel.photoAsset?[indexPath.item - 1] else { return }
            Task {
                await LocalPhotoManager.shared.requestImage(with: asset) { [weak self] image in
                    guard let self else { return }
                    let editViewController = EditPhotoViewController()
                    editViewController.setPhoto(image: image)
                    self.navigationController?.pushViewController(editViewController, animated: true)
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
        
        if indexPath.item == 0 {
            cell.setPhoto(.photo)
        } else {
            guard let asset = viewModel.photoAsset?[indexPath.item - 1] else { return cell }
            let cellSize = cell.bounds.size
            Task {
                await LocalPhotoManager.shared.requestImage(with: asset, cellSize: cellSize) { image in
                    cell.setPhoto(image)
                }
            }
        }
        return cell
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension CustomAlbumViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        dismiss(animated: true)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let editViewController = EditPhotoViewController()
            editViewController.setPhoto(image: image)
            self.navigationController?.pushViewController(editViewController, animated: true)
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension CustomAlbumViewController: PHPhotoLibraryChangeObserver {
    nonisolated func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { @MainActor in
            viewModel.action(.photoDidChanged(changeInstance))
        }
    }
}
