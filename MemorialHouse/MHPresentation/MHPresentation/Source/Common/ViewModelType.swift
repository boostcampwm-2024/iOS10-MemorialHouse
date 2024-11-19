import Combine

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}
