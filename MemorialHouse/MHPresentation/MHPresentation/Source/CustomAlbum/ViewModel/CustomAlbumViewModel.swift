import MHFoundation
import Photos
import Combine

final class CustomAlbumViewModel: ViewModelType {
    enum Input {
        case viewDidLoad
        case photoDidChanged(to: PHChange)
    }
    
    enum Output {
        case fetchAssets
        case changedAssets(with: PHFetchResultChangeDetails<PHAsset>)
    }
    
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private(set) var photoAsset: PHFetchResult<PHAsset>?
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                self?.fetchPhotoAssets()
            case .photoDidChanged(let changeInstance):
                self?.updatePhotoAssets(changeInstance)
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func fetchPhotoAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        photoAsset = PHAsset.fetchAssets(with: fetchOptions)
        output.send(.fetchAssets)
    }
    
    private func updatePhotoAssets(_ changeInstance: PHChange) {
        guard let asset = self.photoAsset,
              let changes = changeInstance.changeDetails(for: asset) else { return }
        
        self.photoAsset = changes.fetchResultAfterChanges
        
        if changes.hasIncrementalChanges {
            output.send(.changedAssets(with: changes))
        }
    }
}
