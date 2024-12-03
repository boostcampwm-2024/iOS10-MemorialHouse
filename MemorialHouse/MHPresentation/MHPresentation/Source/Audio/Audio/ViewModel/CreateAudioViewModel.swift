import Foundation
import MHData
import Combine
import MHCore

final class CreateAudioViewModel: ViewModelType {
    // MARK: - Type
    enum Input {
        case viewDidLoad
        case audioButtonTapped
        case saveButtonTapped
        case recordCancelled
    }
    enum Output {
        case audioFileURL(url: URL)
        case audioStart
        case audioStop
        case recordCompleted
    }
    
    // MARK: - Property
    private let output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var audioIsRecoding: Bool = false
    private let completion: (Result<URL, Error>) -> Void
    private let forBookID: UUID
    private var fileURL: URL?
    
    // MARK: - Initializer
    init(forBookID: UUID, completion: @escaping (Result<URL, Error>) -> Void) {
        self.forBookID = forBookID
        self.completion = completion
    }
    
    // MARK: - Method
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidLoad:
                Task { await self?.viewDidLoad() }
            case .audioButtonTapped:
                self?.audioButtonTapped()
            case .saveButtonTapped:
                self?.completeRecord(withCompletion: true)
            case .recordCancelled:
                self?.completeRecord(withCompletion: false)
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    // MARK: - Helper
    private func viewDidLoad() async {
        do {
            let url = try await MHFileManager(directoryType: .documentDirectory)
                .getURL(at: forBookID.uuidString, fileName: "temp.m4a")
                .get()
            fileURL = url
            output.send(.audioFileURL(url: url))
        } catch {
            MHLogger.error("Error in getting audio file url: \(error.localizedDescription)")
            completion(.failure(error))
            output.send(.recordCompleted)
        }
    }
    private func audioButtonTapped() {
        switch audioIsRecoding {
        case false:
            output.send(.audioStart)
        case true:
            output.send(.audioStop)
        }
        audioIsRecoding.toggle()
    }
    
    private func completeRecord(withCompletion: Bool) {
        if audioIsRecoding {
            output.send(.audioStop)
        }
        output.send(.recordCompleted)
        if withCompletion, let fileURL {
            completion(.success(fileURL))
        }
    }
}
