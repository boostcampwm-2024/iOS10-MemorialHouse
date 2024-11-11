import MHFoundation
import Photos
import Combine

final class CustomAlbumViewModel {
    enum Input {
        case viewDidLoad
    }
    // MARK: - Properties
    @Published private(set) var photoAsset: PHFetchResult<PHAsset>?
    
    func action(_ input: CustomAlbumViewModel.Input) {
        switch input {
        case .viewDidLoad:
            fetchPhotoAssets()
        }
    }
    
    private func fetchPhotoAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        photoAsset = PHAsset.fetchAssets(with: fetchOptions)
    }
}
