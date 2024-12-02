import MHCore
import UIKit
import Photos
import Combine

final class CustomAlbumViewController: UIViewController {
    // MARK: - UI Components
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
    
    // MARK: - Properties
    private let viewModel: CustomAlbumViewModel
    private let input = PassthroughSubject<CustomAlbumViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let mediaType: PHAssetMediaType
    
    // MARK: - Initializer
    init(viewModel: CustomAlbumViewModel, mediaType: PHAssetMediaType) {
        self.viewModel = viewModel
        self.mediaType = mediaType
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = CustomAlbumViewModel()
        self.mediaType = .image
        
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureConstraints()
        configureNavigationBar()
        bind()
        input.send(.viewDidLoad(mediaType: mediaType))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationAppearance()
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
    
    private func configureNavigationBar() {
        // TODO: - 추후 삭제 필요
        navigationController?.navigationBar.isHidden = false
        if mediaType == .image {
            navigationItem.title = "사진 선택"
        } else {
            navigationItem.title = "동영상 선택"
        }
        
        // 공통 스타일 정의
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ownglyphBerry(size: 17),
            .foregroundColor: UIColor.mhTitle
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ownglyphBerry(size: 17)
        ]
        
        // Left Bar Button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "닫기",
            normal: normalAttributes,
            selected: selectedAttributes
        ) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func configureNavigationAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .baseBackground
        navigationBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.ownglyphBerry(size: 17),
            NSAttributedString.Key.foregroundColor: UIColor.mhTitle
        ]
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.compactAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    }
    
    // MARK: - Binding
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output.receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchAssets:
                    self?.albumCollectionView.reloadData()
                case .changedAssets(let changes):
                    self?.albumCollectionView.performBatchUpdates {
                        if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                            self?.albumCollectionView.insertItems(
                                at: inserted.map({ IndexPath(item: $0 + 1, section: 0) })
                            )
                        }
                        if let removed = changes.removedIndexes, !removed.isEmpty {
                            self?.albumCollectionView.deleteItems(
                                at: removed.map({ IndexPath(item: $0 + 1, section: 0) })
                            )
                        }
                    }
                }
            }
            .store(in: &cancellables)
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
                }
            }
        case .authorized:
            openCamera()
        case .restricted, .denied:
            showsRedirectSettingAlert(with: .camera)
            MHLogger.info("카메라 권한 거부")
        default:
            MHLogger.error(authorization)
        }
    }
    
    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            if mediaType == .video {
                imagePicker.mediaTypes = ["public.movie"]
                imagePicker.cameraCaptureMode = .video
            }
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
                await LocalPhotoManager.shared.requestThumbnailImage(with: asset) { [weak self] image in
                    guard let self else { return }
                    if self.mediaType == .image {
                        let editPhotoViewController = EditPhotoViewController()
                        editPhotoViewController.setPhoto(image: image, date: asset.creationDate)
                        self.navigationController?.pushViewController(editPhotoViewController, animated: true)
                    } else {
                        let editVideoViewController = EditVideoViewController()
                        
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
        
        if indexPath.item == 0 {
            cell.setPhoto(.photo)
        } else {
            guard let asset = viewModel.photoAsset?[indexPath.item - 1] else { return cell }
            let cellSize = cell.bounds.size
            Task {
                await LocalPhotoManager.shared.requestThumbnailImage(with: asset, cellSize: cellSize) { image in
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
            editViewController.setPhoto(image: image, date: .now)
            self.navigationController?.pushViewController(editViewController, animated: true)
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension CustomAlbumViewController: PHPhotoLibraryChangeObserver {
    nonisolated func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { @MainActor in
            input.send(.photoDidChanged(to: changeInstance))
        }
    }
}
