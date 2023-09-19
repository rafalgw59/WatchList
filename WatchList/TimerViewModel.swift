
import SwiftUI

class TimerViewModel: ObservableObject {
    @Published var countdownText: String = ""
    private var timer: Timer?

    func startCountdownTimer(targetDate: Date) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            let timeRemaining = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: targetDate)

            self.countdownText = "Release In: \(timeRemaining.day ?? 0)d \(timeRemaining.hour ?? 0)h \(timeRemaining.minute ?? 0)m \(timeRemaining.second ?? 0)s"
        }
    }

    func stopCountdownTimer() {
        timer?.invalidate()
        timer = nil
        countdownText = ""
    }
}
