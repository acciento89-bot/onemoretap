import AVFoundation
import Combine

/// One quiet original loop for all screens; no background-audio entitlement.
@MainActor
final class BackgroundMusic: ObservableObject {
    private var policy = MusicPlaybackState()
    private var player: AVAudioPlayer?
    private var observers = Set<AnyCancellable>()
    private let session = AVAudioSession.sharedInstance()

    init() {
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
            .sink { [weak self] note in
                let kind = (note.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue
                let options = (note.userInfo?[AVAudioSessionInterruptionOptionKey] as? NSNumber)?.uintValue ?? 0
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    if kind == AVAudioSession.InterruptionType.began.rawValue { self.policy.interruptionBegan() }
                    else if kind == AVAudioSession.InterruptionType.ended.rawValue {
                        self.policy.interruptionEnded(shouldResume: AVAudioSession.InterruptionOptions(rawValue: options).contains(.shouldResume))
                    }
                    self.synchronize()
                }
            }.store(in: &observers)
        NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)
            .sink { [weak self] note in
                let reason = (note.userInfo?[AVAudioSessionRouteChangeReasonKey] as? NSNumber)?.uintValue
                guard reason == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue else { return }
                Task { @MainActor [weak self] in self?.policy.hold(); self?.synchronize() }
            }.store(in: &observers)
    }
    func update(foreground: Bool, enabled: Bool) {
        policy.setForeground(foreground)
        policy.setEnabled(enabled)
        synchronize()
    }
    private func synchronize() {
        guard policy.shouldPlay else {
            player?.pause()
            try? session.setActive(false, options: .notifyOthersOnDeactivation)
            return
        }
        guard player?.isPlaying != true else { return }
        // Respect other audio and the hardware silent switch, without taking its focus.
        guard !session.isOtherAudioPlaying else { return }
        do {
            try session.setCategory(.ambient, mode: .default)
            try session.setActive(true)
            if player == nil {
                guard let url = Bundle.main.url(forResource: "pulse_garden", withExtension: "wav") else { return }
                let loop = try AVAudioPlayer(contentsOf: url)
                loop.numberOfLoops = -1
                loop.volume = 0.65
                loop.prepareToPlay()
                player = loop
            }
            player?.play()
        } catch {
            // Audio is optional; an unavailable route must never block gameplay.
            player?.pause()
        }
    }
}
