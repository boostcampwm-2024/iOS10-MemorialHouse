import UIKit
import Photos

struct LocalPhotoManager {
    private let imageManager = PHCachingImageManager()
    private let imageRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        
        return options
    }()
    
    func requestThumbnailImage(
        with asset: PHAsset?,
        cellSize: CGSize = .zero,
        completion: @escaping @MainActor (UIImage?) -> Void
    ) {
        guard let asset else { return }
        
        imageManager.requestImage(
            for: asset,
            targetSize: cellSize,
            contentMode: .aspectFill,
            options: imageRequestOptions,
            resultHandler: { image, _ in
                Task { await completion(image) }
        })
        
        imageManager.startCachingImages(
            for: [asset],
            targetSize: cellSize,
            contentMode: .aspectFill,
            options: nil
        )
    }
    
    func requestVideoURL(
        with asset: PHAsset,
        completion: @escaping @MainActor (URL?) -> Void
    ) {
        let options = PHVideoRequestOptions()
        options.version = .current
        imageManager.requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
            let url = (avAsset as? AVURLAsset)?.url
            Task { await completion(url) }
        }
    }
}
