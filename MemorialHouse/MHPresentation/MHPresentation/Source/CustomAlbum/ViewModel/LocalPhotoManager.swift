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
    
    func requestImage(
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
}
