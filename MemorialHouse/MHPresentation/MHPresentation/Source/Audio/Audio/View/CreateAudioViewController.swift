import UIKit
import AVFoundation
import Combine
import MHCore

final class CreateAudioViewController: UIViewController {
    // MARK: - Property
    // data bind
    private var viewModel: CreateAudioViewModel?
    private let input = PassthroughSubject<CreateAudioViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    // auido
    private var audioRecorder: AVAudioRecorder?
    // auido metering
    private var upBarLayers: [CALayer] = []
    private var downBarLayers: [CALayer] = []
    private let numberOfBars = 30
    private let volumeHalfHeight: CGFloat = 40
    // timer
    private var recordingSeconds: Int = 0
    private var meteringLevelTimer: Timer?
    private var recordTimer: Timer?
    // audio session
    private let audioSession = AVAudioSession.sharedInstance()
    private let audioRecordersettings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
    ]
    
    // MARK: - UI Component
    // title and buttons
    private var stackView = UIStackView()
    private let titleLabel: UITextField = {
        let textField = UITextField(
            frame: CGRect(origin: .zero, size: CGSize(width: 120, height: 28))
        )
        textField.text = "소리 기록"
        textField.font = UIFont.ownglyphBerry(size: 28)
        textField.textAlignment = .center
        textField.textColor = .black
        return textField
    }()
    private let cancelButton: UIButton = {
        let button = UIButton(
            frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 21))
        )
        var attributedString = AttributedString(stringLiteral: "취소")
        attributedString.font = UIFont.ownglyphBerry(size: 21)
        attributedString.foregroundColor = UIColor.black
        button.setAttributedTitle(NSAttributedString(attributedString), for: .normal)
        return button
    }()
    private let saveButton: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 21)))
        button.contentHorizontalAlignment = .center
        button.setAttributedTitle(
            NSAttributedString(
                string: "저장",
                attributes: [.font: UIFont.ownglyphBerry(size: 21), .foregroundColor: UIColor.mhTitle]
            ),
            for: .normal
        )
        button.setAttributedTitle(
            NSAttributedString(
                string: "저장",
                attributes: [.font: UIFont.ownglyphBerry(size: 21), .foregroundColor: UIColor.systemGray2]
            ),
            for: .disabled
        )
        return button
    }()
    // audio metering
    private var meteringBackgroundView: UIView = UIView()
    private var upMeteringView: UIView = UIView()
    private var downMeteringView: UIView = UIView()
    private let audioButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .red
        return button
    }()
    private let audioButtonBackground = {
        let buttonBackground = UIView()
        buttonBackground.layer.borderWidth = 4
        buttonBackground.layer.borderColor = UIColor.gray.cgColor
        buttonBackground.layer.cornerRadius = 30
        
        return buttonBackground
    }()
    private var audioButtonConstraints: [NSLayoutConstraint] = []
    // timer
    private var timeTextLabel: UITextField = {
        let textField = UITextField()
        textField.text = "00:00"
        textField.textColor = .black
        textField.font = UIFont.ownglyphBerry(size: 16)
        
        return textField
    }()
    
    // MARK: - Initializer
    init(viewModel: CreateAudioViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        guard let viewModelFactory = try? DIContainer.shared.resolve(CreateAudioViewModelFactory.self) else {
            return nil
        }
        self.viewModel = viewModelFactory.make { _ in }
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
        configureAddSubviews()
        configureConstraints()
        configureAddActions()
        input.send(.prepareTemporaryAudio)
    }
    
    // MARK: - Setup
    private func setup() {
        view.backgroundColor = .white
        setupBars()
        requestMicrophonePermission()
    }
    
    private func setupBars() {
        let width = 300 / numberOfBars - 5
        let barSpacing = 5
        
        for index in 0..<numberOfBars {
            let upMeteringLayer = CALayer()
            upMeteringLayer.backgroundColor = UIColor.mhOrange.cgColor
            upMeteringLayer.frame = CGRect(
                x: index * (width + barSpacing),
                y: Int(volumeHalfHeight),
                width: width,
                height: -2
            )
            upMeteringView.layer.addSublayer(upMeteringLayer)
            upBarLayers.append(upMeteringLayer)
            
            let downMeteringLayer = CALayer()
            downMeteringLayer.backgroundColor = UIColor.mhOrange.cgColor
            downMeteringLayer.frame = CGRect(
                x: index * (width + barSpacing),
                y: 0,
                width: width,
                height: 2
            )
            downMeteringView.layer.addSublayer(downMeteringLayer)
            downBarLayers.append(downMeteringLayer)
        }
    }
    
    private func setupBarsDefault() {
        let width = 300 / numberOfBars - 5
        let barSpacing = 5
        
        for index in 0..<numberOfBars {
            upBarLayers[index].frame = CGRect(
                x: index * (width + barSpacing),
                y: Int(volumeHalfHeight),
                width: width,
                height: -2
            )
            
            downBarLayers[index].frame = CGRect(
                x: index * (width + barSpacing),
                y: 0,
                width: width,
                height: 2
            )
        }
    }
    
    // MARK: - bind
    private func bind() {
        let output = viewModel?.transform(input: input.eraseToAnyPublisher())
        output?.receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] event in
                switch event {
                case let .audioFileURL(url):
                    self?.configureAudioSession(for: url)
                case .audioStart:
                    self?.startRecording()
                case .audioStop:
                    self?.stopRecording()
                case .recordCompleted:
                    self?.dismiss(animated: true)
                }
            }).store(in: &cancellables)
    }
    
    // MARK: - Configuration
    private func configureAudioSession(for url: URL) {
        try? audioSession.setCategory(.record, mode: .default)
        
        audioRecorder = try? AVAudioRecorder(url: url, settings: audioRecordersettings)
        audioRecorder?.isMeteringEnabled = true
    }
    
    private func configureAddSubviews() {
        stackView = UIStackView(arrangedSubviews: [cancelButton, titleLabel, saveButton])
        view.addSubview(stackView)
        view.addSubview(meteringBackgroundView)
        view.addSubview(audioButtonBackground)
        audioButtonBackground.addSubview(audioButton)
        view.addSubview(timeTextLabel)
    }
    
    private func configureConstraints() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        cancelButton.setWidth(60)
        saveButton.setWidth(60)
        
        stackView.setCenterX(view: view)
        stackView.setAnchor(
            top: view.topAnchor, constantTop: -10,
            leading: view.leadingAnchor, constantLeading: 25,
            trailing: view.trailingAnchor, constantTrailing: 25,
            height: 120
        )
        // meteringBackgroundView
        meteringBackgroundView.layer.cornerRadius = 25
        meteringBackgroundView.backgroundColor = UIColor.mhPink
        meteringBackgroundView.setCenterX(view: view)
        meteringBackgroundView.setAnchor(top: titleLabel.bottomAnchor, constantTop: 24)
        meteringBackgroundView.setWidthAndHeight(width: 320, height: volumeHalfHeight * 2)
        
        // metering level view
        meteringBackgroundView.addSubview(upMeteringView)
        upMeteringView.setCenter(view: meteringBackgroundView, offset: CGPoint(x: 0, y: -volumeHalfHeight/2))
        upMeteringView.setWidthAndHeight(width: 300, height: volumeHalfHeight)
        
        meteringBackgroundView.addSubview(downMeteringView)
        downMeteringView.setCenter(view: meteringBackgroundView, offset: CGPoint(x: 0, y: volumeHalfHeight/2))
        downMeteringView.setWidthAndHeight(width: 300, height: volumeHalfHeight)
        
        // audio button
        audioButtonBackground.setAnchor(top: meteringBackgroundView.bottomAnchor, constantTop: 20)
        audioButtonBackground.setCenterX(view: view)
        audioButtonBackground.setWidthAndHeight(width: 60, height: 60)
        
        audioButton.layer.cornerRadius = 24
        audioButton.setWidthAndHeight(width: 48, height: 48)
        audioButton.setCenter(view: audioButtonBackground)
        
        timeTextLabel.setAnchor(
            top: meteringBackgroundView.bottomAnchor, constantTop: 10,
            trailing: meteringBackgroundView.trailingAnchor
        )
        timeTextLabel.setWidthAndHeight(width: 60, height: 16)
    }
    
    private func configureAddActions() {
        addTappedEventToAudioButton()
        addTappedEventToCancelButton()
        addTappedEventToSaveButton()
    }
    
    private func addTappedEventToAudioButton() {
        audioButton.addAction(
            UIAction { [weak self] _ in
                self?.input.send(.audioButtonTapped)
            }, for: .touchUpInside
        )
    }
    
    private func addTappedEventToCancelButton() {
        cancelButton.addAction(
            UIAction { [weak self] _ in
                self?.input.send(.recordCancelled)
            }, for: .touchUpInside
        )
    }
    
    private func addTappedEventToSaveButton() {
        saveButton.addAction(
            UIAction { [weak self] _ in
                self?.input.send(.saveButtonTapped)
            }, for: .touchUpInside
        )
    }
    
    // MARK: - Helper
    private func requestMicrophonePermission() {
        Task {
            AVAudioSession.sharedInstance().requestRecordPermission { @Sendable granted in
                Task { @MainActor in
                    if !granted {
                        self.showRedirectSettingAlert(with: .audio)
                    }
                }
            }
        }
    }
    
    private func startRecording() {
        setupBarsDefault()
        try? audioSession.setActive(true)
        
        timeTextLabel.text = "00:00"
        
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()
        // timer about audio metering level
        meteringLevelTimer?.invalidate()
        meteringLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task {
                if await (self?.audioRecorder?.isRecording ?? true) {
                    await self?.updateAudioMetering()
                }
            }
        }
        // timer about audio record time
        recordTimer?.invalidate()
        recordTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.recordingSeconds += 1
                self?.setTimeLabel(seconds: self?.recordingSeconds)
            }
        }
        
        // audio button to start
        audioButtonSetStartImage()
        audioButton.layer.cornerRadius = 6
        NSLayoutConstraint.deactivate(audioButton.constraints)
        audioButton.setWidthAndHeight(width: 32, height: 32)
        audioButton.setCenter(view: audioButtonBackground)
        NSLayoutConstraint.activate(audioButton.constraints)
        
        saveButton.isEnabled = false
    }
    
    private func stopRecording() {
        try? audioSession.setActive(false)
        
        audioRecorder?.stop()
        recordTimer?.invalidate()
        
        recordingSeconds = 0
        
        // audio button to stop
        audioButtonSetRotateImage()
        NSLayoutConstraint.deactivate(audioButton.constraints)
        audioButton.setWidthAndHeight(width: 48, height: 48)
        audioButton.setCenter(view: audioButtonBackground)
        NSLayoutConstraint.activate(audioButton.constraints)
        
        saveButton.isEnabled = true
    }
    
    private func audioButtonSetRotateImage() {
        let image = UIImage(
            systemName: "arrow.clockwise",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 36)
        )
        audioButton.setImage(image, for: .normal)
        audioButton.tintColor = .black
        
        audioButton.backgroundColor = .white
        audioButtonBackground.layer.borderColor = UIColor.white.cgColor
    }
    
    private func audioButtonSetStartImage() {
        audioButton.setImage(nil, for: .normal)
        audioButton.backgroundColor = .red
        audioButtonBackground.layer.borderColor = UIColor.gray.cgColor
    }
    
    private func updateAudioMetering() {
        guard let recorder = audioRecorder else { return }
        recorder.updateMeters()
        
        let decibel = CGFloat(recorder.averagePower(forChannel: 0))
        let baseDecibel: CGFloat = -60.0
        let meteringLevel = pow(10, (decibel - baseDecibel) / 30)
        
        let barHeight = min(meteringLevel, volumeHalfHeight - 4)
        
        for index in 0..<numberOfBars-1 {
            upBarLayers[index].frame = CGRect(
                x: upBarLayers[index].frame.origin.x,
                y: volumeHalfHeight,
                width: upBarLayers[index].frame.width,
                height: -upBarLayers[index+1].frame.height
            )
            
            downBarLayers[index].frame = CGRect(
                x: downBarLayers[index].frame.origin.x,
                y: 0,
                width: downBarLayers[index].frame.width,
                height: downBarLayers[index+1].frame.height
            )
        }
        
        upBarLayers[numberOfBars-1].frame = CGRect(
            x: upBarLayers[numberOfBars-1].frame.origin.x,
            y: volumeHalfHeight,
            width: upBarLayers[numberOfBars-1].frame.width,
            height: barHeight > 2 ? -barHeight : -2
        )
        
        downBarLayers[numberOfBars-1].frame = CGRect(
            x: downBarLayers[numberOfBars-1].frame.origin.x,
            y: 0,
            width: downBarLayers[numberOfBars-1].frame.width,
            height: barHeight > 2 ? barHeight : 2
        )
    }
    
    private func setTimeLabel(seconds recordingSeconds: Int?) {
        guard let recordingSeconds = recordingSeconds else { return }
        let minutes = recordingSeconds / 60
        let seconds = recordingSeconds % 60
        timeTextLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
}
