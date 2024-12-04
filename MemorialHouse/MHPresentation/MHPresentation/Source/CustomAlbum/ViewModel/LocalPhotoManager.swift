import UIKit
import Photos

actor LocalPhotoManager {
    static let shared = LocalPhotoManager()
    
    private let imageManager = PHCachingImageManager()
    private let imageRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        
        return options
    }()
    
    private init() { }
    
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
        with asset: PHAsset
    ) async -> URL? {
        await withCheckedContinuation { continuation in
            let options = PHVideoRequestOptions()
            options.version = .current
            imageManager.requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
                if let urlAsset = avAsset as? AVURLAsset {
                    continuation.resume(returning: urlAsset.url)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
