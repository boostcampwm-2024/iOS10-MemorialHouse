import MHFoundation
import MHDomain

protocol MediaAttachable {
    func configureSource(with mediaDescription: MediaDescription, data: Data)
    func configureSource(with mediaDescription: MediaDescription, url: URL)
}
