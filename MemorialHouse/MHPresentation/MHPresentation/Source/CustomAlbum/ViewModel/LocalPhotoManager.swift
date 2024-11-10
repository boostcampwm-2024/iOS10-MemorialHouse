import UIKit
import Photos

final class LocalPhotoManager {
    nonisolated(unsafe) static let shared = LocalPhotoManager()
    private let imageManager = PHImageManager()
    private init() { }
    
    func requestIamge(with asset: PHAsset?, cellSize: CGSize = .zero, completion: @escaping (UIImage?) -> Void) {
        guard let asset else { return }
        
        imageManager.requestImage(
            for: asset,
            targetSize: cellSize,
            contentMode: .aspectFill,
            options: nil,
            resultHandler: { image, _ in
            completion(image)
        })
    }
}
