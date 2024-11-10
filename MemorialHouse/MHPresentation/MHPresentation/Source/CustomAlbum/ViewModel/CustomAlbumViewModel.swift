import MHFoundation
import Photos
import Combine

enum CustomAlbumViewModelInput {
    case viewDidLoad
}

final class CustomAlbumViewModel {
    // MARK: - Properties
    @Published private(set) var photoAsset: PHFetchResult<PHAsset>?
    
    init() { }
    
    func action(_ input: CustomAlbumViewModelInput) {
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
