import UIKit
import Photos

actor LocalPhotoManager {
    static let shared = LocalPhotoManager()
    
    private let imageManager = PHImageManager()
    private let imageRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        
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
