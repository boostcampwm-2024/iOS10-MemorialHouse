import UIKit
import Photos

actor LocalPhotoManager {
    static let shared = LocalPhotoManager()
    
    private let imageManager = PHImageManager()
    private let imageRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        return options
    }()
    
    private init() { }
    
    func requestImage(with asset: PHAsset?, cellSize: CGSize = .zero, completion: @escaping (UIImage?) -> Void) {
        guard let asset else { return }
        
        imageManager.requestImage(
            for: asset,
            targetSize: cellSize,
            contentMode: .aspectFill,
            options: imageRequestOptions,
            resultHandler: { image, _ in
            completion(image)
        })
    }
}
