import AudioToolbox
import UIKit

enum FeedbackManager {
    static func lightTap(quietMode: Bool = false) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        if !quietMode {
            AudioServicesPlaySystemSound(1003)
        }
    }

    static func mediumAction(quietMode: Bool = false) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        if !quietMode {
            AudioServicesPlaySystemSound(1003)
        }
    }

    static func taskComplete(quietMode: Bool = false) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        if !quietMode {
            AudioServicesPlaySystemSound(1104)
        }
    }

    static func focusPhaseEnd(quietMode: Bool) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        if !quietMode {
            AudioServicesPlaySystemSound(1103)
        }
    }

    static func habitComplete(quietMode: Bool = false) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        if !quietMode {
            AudioServicesPlaySystemSound(1103)
        }
    }

    static func success(quietMode: Bool = false) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        if !quietMode {
            AudioServicesPlaySystemSound(1057)
        }
    }

    static func warning(quietMode: Bool = false) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    static func achievementUnlocked(quietMode: Bool = false) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        if !quietMode {
            AudioServicesPlaySystemSound(1057)
        }
    }
}
