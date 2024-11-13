import MHFoundation
import Photos
import Combine

final class CustomAlbumViewModel {
    enum Input {
        case viewDidLoad
        case photoDidChanged(_ changeInstance: PHChange)
    }
    // MARK: - Properties
    @Published private(set) var photoAsset: PHFetchResult<PHAsset>?
    let changedAssetsOutput = PassthroughSubject<PHFetchResultChangeDetails<PHAsset>, Never>()
    
    func action(_ input: CustomAlbumViewModel.Input) {
        switch input {
        case .viewDidLoad:
            fetchPhotoAssets()
        case .photoDidChanged(let changeInstance):
            updatePhotoAssets(changeInstance)
        }
    }
    
    private func fetchPhotoAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        photoAsset = PHAsset.fetchAssets(with: fetchOptions)
    }
    
    private func updatePhotoAssets(_ changeInstance: PHChange) {
        guard let asset = self.photoAsset,
              let changes = changeInstance.changeDetails(for: asset) else { return }
        
        self.photoAsset = changes.fetchResultAfterChanges
        
        if changes.hasIncrementalChanges {
            changedAssetsOutput.send(changes)
        }
    }
}
