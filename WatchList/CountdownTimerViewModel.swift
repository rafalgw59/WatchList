
import Foundation

class CountdownTimerViewModel: ObservableObject {
    @Published var countdownText: String = ""
    private var timer: Timer?
    private var targetDate: Date?
    
    func startCountdownTimer(for releaseDate: Date?, nextEpisodeReleaseDate: Date?) {
        guard let targetDate = releaseDate ?? nextEpisodeReleaseDate else {
            return
        }
        
        self.targetDate = targetDate
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCountdown(releaseDate: releaseDate, nextEpisodeReleaseDate: nextEpisodeReleaseDate)
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateCountdown(releaseDate: Date?, nextEpisodeReleaseDate: Date?) {
        guard let targetDate = targetDate else {
            countdownText = ""
            return
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        if now < targetDate {
            let components = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: targetDate)
            let days = components.day ?? 0
            let hours = components.hour ?? 0
            let minutes = components.minute ?? 0
            let seconds = components.second ?? 0
            
            if let releaseDate = releaseDate, now < releaseDate {
                countdownText = "In: \(formatCountdownText(days, hours, minutes, seconds))"
            } else if let nextEpisodeReleaseDate = nextEpisodeReleaseDate, now < nextEpisodeReleaseDate {
                countdownText = "In: \(formatCountdownText(days, hours, minutes, seconds))"
            } else {
                countdownText = ""
                stopTimer()
            }
        } else {
            countdownText = "Released"
            stopTimer()
        }
    }
    
    private func formatCountdownText(_ days: Int, _ hours: Int, _ minutes: Int, _ seconds: Int) -> String {
        return String(format: "%02dd %02dh %02dm %02ds", days, hours, minutes, seconds)
    }
}
