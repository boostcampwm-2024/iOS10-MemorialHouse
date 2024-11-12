import MHDomain
import Photos

struct BookCreationViewModel {
    var bookTitle: String = ""
    var bookCategory: String = ""
    var previousColorNumber: Int = -1
    var currentColorNumber: Int = 0
    var coverPicture: PHAsset?
    var currentColor: BookColor {
        switch currentColorNumber {
        case 0: .pink
        case 1: .green
        case 2: .blue
        case 3: .orange
        case 4: .beige
        default: .blue
        }
    }
}
