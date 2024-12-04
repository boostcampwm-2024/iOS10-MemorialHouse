import Combine
import Testing
@testable import MHPresentation

struct RegisterViewModelTest {
    private var sut: RegisterViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    @MainActor
    @Test mutating func test입력받은_기록소_이름을_저장한다() async throws {
        // Arrange
        let stubUseCase = StubCreateMemorialHouseNameUseCase() // 스텁 설정
        sut = RegisterViewModel(createMemorialHouseNameUseCase: stubUseCase)
        let input = PassthroughSubject<RegisterViewModel.Input, Never>()
        var receivedOutput: [RegisterViewModel.Output] = []
        sut.transform(input: input.eraseToAnyPublisher())
            .sink { output in
                receivedOutput.append(output)
            }
            .store(in: &cancellables)
        
        // Act
        input.send(.registerButtonTapped(memorialHouseName: "집주인들"))
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Assert
        #expect(receivedOutput.count == 1)
        #expect(receivedOutput.contains(.moveToHome))
    }
    
    @MainActor
    @Test mutating func test빈_텍스트필드_입력시_등록버튼이_비활성화된다() throws {
        // Arrange
        let stubUseCase = StubCreateMemorialHouseNameUseCase()
        sut = RegisterViewModel(createMemorialHouseNameUseCase: stubUseCase)
        
        let input = PassthroughSubject<RegisterViewModel.Input, Never>()
        var receivedOutput: [RegisterViewModel.Output] = []
        sut.transform(input: input.eraseToAnyPublisher())
            .sink { output in
                receivedOutput.append(output)
            }
            .store(in: &cancellables)
        
        // Act
        input.send(.registerTextFieldEdited(text: ""))
        
        // Assert
        #expect(receivedOutput.count == 1)
        #expect(receivedOutput.contains(.registerButtonEnabled(isEnabled: false)))
    }
    
    @MainActor
    @Test mutating func test기록소_이름이_11글자_이상이면_등록버튼이_비활성화된다() throws {
        // Arrange
        let stubUseCase = StubCreateMemorialHouseNameUseCase()
        sut = RegisterViewModel(createMemorialHouseNameUseCase: stubUseCase)
        
        let input = PassthroughSubject<RegisterViewModel.Input, Never>()
        var receivedOutput: [RegisterViewModel.Output] = []
        sut.transform(input: input.eraseToAnyPublisher())
            .sink { output in
                receivedOutput.append(output)
            }
            .store(in: &cancellables)
        
        // Act
        input.send(.registerTextFieldEdited(text: "이름이_너무너무너무너무_길어요"))
        
        // Assert
        #expect(receivedOutput.count == 1)
        #expect(receivedOutput.contains(.registerButtonEnabled(isEnabled: false)))
    }
    
    @MainActor
    @Test mutating func test기록소_이름_입력시_등록버튼이_활성화된다() throws {
        // Arrange
        let stubUseCase = StubCreateMemorialHouseNameUseCase()
        sut = RegisterViewModel(createMemorialHouseNameUseCase: stubUseCase)
        
        let input = PassthroughSubject<RegisterViewModel.Input, Never>()
        var receivedOutput: [RegisterViewModel.Output] = []
        sut.transform(input: input.eraseToAnyPublisher())
            .sink { output in
                receivedOutput.append(output)
            }
            .store(in: &cancellables)
        
        // Act
        input.send(.registerTextFieldEdited(text: "올바른 이름"))
        
        // Assert
        #expect(receivedOutput.count == 1)
        #expect(receivedOutput.contains(.registerButtonEnabled(isEnabled: true)))
    }
}
