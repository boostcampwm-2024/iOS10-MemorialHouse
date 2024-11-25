import Combine

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    @MainActor
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}
