import MHCore
import UIKit
import Photos
import Combine
import PhotosUI

final class CustomAlbumViewController: UIViewController {
    enum Mode {
        case bookCover
        case editPage
    }
    
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
    private let mode: Mode
    private let videoSelectCompletionHandler: ((URL) -> Void)?
    private let photoSelectCompletionHandler: ((Data, Date?, String?) -> Void)?
    
    // MARK: - Initializer
    init(
        viewModel: CustomAlbumViewModel,
        mediaType: PHAssetMediaType,
        mode: Mode = .editPage,
        videoSelectCompletionHandler: ((URL) -> Void)? = nil,
        photoSelectCompletionHandler: ((Data, Date?, String?) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.mediaType = mediaType
        self.mode = mode
        self.videoSelectCompletionHandler = videoSelectCompletionHandler
        self.photoSelectCompletionHandler = photoSelectCompletionHandler
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = CustomAlbumViewModel()
        self.mediaType = .image
        self.mode = .bookCover
        self.videoSelectCompletionHandler = { _ in }
        self.photoSelectCompletionHandler = { _, _, _ in }
        
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
        checkThumbnailAuthorization()
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
            self?.dismiss(animated: true)
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
    
    // MARK: - Media
    private func checkThumbnailAuthorization() {
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        switch authorization {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { @Sendable [weak self] status in
                Task { @MainActor in
                    guard let self = self else { return }
                    if status == .authorized || status == .limited {
                        self.input.send(.viewDidLoad(mediaType: self.mediaType))
                    } else {
                        self.dismiss(animated: true)
                    }
                }
            }
        case .authorized, .limited:
            input.send(.viewDidLoad(mediaType: mediaType))
        case .restricted, .denied:
            showRedirectSettingAlert(with: .image)
            MHLogger.info("앨범 접근 권한 거부로 뷰를 닫았습니다.")
        default:
            showRedirectSettingAlert(with: .image)
            MHLogger.error("알 수 없는 권한 상태로 인해 뷰를 닫았습니다.")
        }
    }
    
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
            albumCollectionView.reloadData()
        case .restricted, .denied:
            showRedirectSettingAlert(with: .camera)
            MHLogger.info("카메라 권한 거부")
        default:
            showRedirectSettingAlert(with: .camera)
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
    private func moveToEditPhotoView(image: UIImage?, creationDate: Date) {
        guard let photoSelectCompletionHandler else { return }
        var editPhotoViewController: EditPhotoViewController
        switch mode {
        case .bookCover:
            editPhotoViewController = EditPhotoViewController(
                mode: .bookCover,
                completionHandler: photoSelectCompletionHandler
            )
        case .editPage:
            editPhotoViewController = EditPhotoViewController(
                mode: .editPage,
                creationDate: creationDate,
                completionHandler: photoSelectCompletionHandler
            )
        }
        editPhotoViewController.setPhoto(image: image)
        self.navigationController?.pushViewController(editPhotoViewController, animated: true)
    }
    
    private func moveToEditVideoView(url: URL) {
        guard let videoSelectCompletionHandler else { return }
        let editVideoViewController = EditVideoViewController(
            videoURL: url,
            videoSelectCompletionHandler: videoSelectCompletionHandler
        )
        self.navigationController?.pushViewController(editVideoViewController, animated: true)
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
            
            if self.mediaType == .image {
                handleImageSelection(with: asset)
            } else {
                handleVideoSelection(with: asset)
            }
        }
    }
    
    private func handleImageSelection(with asset: PHAsset) {
        Task {
            await LocalPhotoManager.shared.requestThumbnailImage(with: asset) { [weak self] image in
                guard let self = self, let image = image else { return }
                self.moveToEditPhotoView(image: image, creationDate: asset.creationDate ?? .now)
            }
        }
    }
    
    private func handleVideoSelection(with asset: PHAsset) {
        Task {
            if let videoURL = await LocalPhotoManager.shared.requestVideoURL(with: asset) {
                MHLogger.info("\(#function) 비디오 URL: \(videoURL)")
                self.moveToEditVideoView(url: videoURL)
            } else {
                self.showErrorAlert(with: "비디오 URL을 가져올 수 없습니다.")
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
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        moveToEditPhotoView(image: image, creationDate: .now)
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
