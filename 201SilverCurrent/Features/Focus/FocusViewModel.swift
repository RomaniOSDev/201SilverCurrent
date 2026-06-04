import AudioToolbox
import Combine
import Foundation
import SwiftUI
import UIKit

enum FocusTimerState {
    case idle
    case running
    case paused
    case onBreak
}

enum FocusPreset: String, CaseIterable, Identifiable {
    case short = "25/5"
    case long = "50/10"
    case deepWork = "Deep 90"
    case quick15 = "Quick 15"
    case custom = "Custom"

    var id: String { rawValue }

    var focusMinutes: Int? {
        switch self {
        case .short: return 25
        case .long: return 50
        case .deepWork: return 90
        case .quick15: return 15
        case .custom: return nil
        }
    }

    var breakMinutes: Int? {
        switch self {
        case .short: return 5
        case .long: return 10
        case .deepWork: return 15
        case .quick15: return 3
        case .custom: return nil
        }
    }
}

final class FocusViewModel: ObservableObject {
    @Published var timerState: FocusTimerState = .idle
    @Published var isFocusPhase = true
    @Published var showSettings = false
    @Published var showStatistics = false
    @Published var glowActive = false
    @Published var showSuccessFlash = false

    private var endDate: Date?
    private var pausedRemaining: Int = 0
    private weak var store: AppDataStore?

    func bind(store: AppDataStore) {
        self.store = store
    }

    var cycleLabel: String {
        guard let store else { return "Cycle 1" }
        return "Cycle \(store.currentCycle)"
    }

    var sessionsLabel: String {
        guard let store else { return "0 sessions completed" }
        return "\(store.completedSessions) sessions completed"
    }

    var showsEmptyPlaceholder: Bool {
        timerState == .idle && (store?.completedSessions ?? 0) == 0
    }

    func applyPreset(_ preset: FocusPreset, store: AppDataStore) {
        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
        store.focusPreset = preset.rawValue
        guard timerState == .idle else { return }
        if let focus = preset.focusMinutes, let breakMin = preset.breakMinutes {
            store.focusDurationSec = focus * 60
            store.breakDurationSec = breakMin * 60
            isFocusPhase = true
        }
    }

    func start(store: AppDataStore) {
        FeedbackManager.mediumAction(quietMode: store.quietFocusMode)
        if timerState == .paused {
            timerState = isFocusPhase ? .running : .onBreak
            endDate = Date().addingTimeInterval(TimeInterval(pausedRemaining))
        } else {
            timerState = .running
            isFocusPhase = true
            let duration = store.focusDurationSec
            pausedRemaining = duration
            endDate = Date().addingTimeInterval(TimeInterval(duration))
        }
    }

    func pause(store: AppDataStore) {
        guard timerState == .running || timerState == .onBreak else { return }
        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
        if let end = endDate {
            pausedRemaining = max(0, Int(end.timeIntervalSinceNow.rounded(.up)))
        }
        timerState = .paused
        endDate = nil
    }

    func stop(store: AppDataStore) {
        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
        timerState = .idle
        endDate = nil
        isFocusPhase = true
        pausedRemaining = store.focusDurationSec
    }

    func resetSessionData(store: AppDataStore) {
        FeedbackManager.warning(quietMode: store.quietFocusMode)
        stop(store: store)
        store.completedSessions = 0
        store.currentCycle = 1
    }

    func remainingSeconds(at now: Date, store: AppDataStore) -> Int {
        switch timerState {
        case .idle:
            return store.focusDurationSec
        case .paused:
            return pausedRemaining
        case .running, .onBreak:
            guard let end = endDate else { return pausedRemaining }
            return max(0, Int(end.timeIntervalSince(now).rounded(.up)))
        }
    }

    func handleTimelineTick(now: Date, store: AppDataStore, isActive: Bool) {
        guard isActive else { return }
        guard timerState == .running || timerState == .onBreak else { return }
        guard let end = endDate, now >= end else { return }
        completePhase(store: store)
    }

    private func completePhase(store: AppDataStore) {
        let quiet = store.quietFocusMode
        if isFocusPhase {
            let minutes = max(1, store.focusDurationSec / 60)
            store.completeFocusSession(durationMinutes: minutes, taskId: store.activeFocusTaskId)
            FeedbackManager.focusPhaseEnd(quietMode: quiet)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            if !quiet {
                AudioServicesPlaySystemSound(1057)
            }
            glowActive = true
            showSuccessFlash = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.glowActive = false
            }
            isFocusPhase = false
            let breakDuration = store.breakDurationSec
            pausedRemaining = breakDuration
            timerState = .onBreak
            endDate = Date().addingTimeInterval(TimeInterval(breakDuration))
        } else {
            store.currentCycle += 1
            isFocusPhase = true
            let focusDuration = store.focusDurationSec
            pausedRemaining = focusDuration
            timerState = .running
            endDate = Date().addingTimeInterval(TimeInterval(focusDuration))
            FeedbackManager.mediumAction(quietMode: quiet)
        }
    }

    func progress(at now: Date, store: AppDataStore) -> Double {
        let total: Int
        switch timerState {
        case .idle:
            total = store.focusDurationSec
        case .paused:
            total = isFocusPhase ? store.focusDurationSec : store.breakDurationSec
        case .running, .onBreak:
            total = isFocusPhase ? store.focusDurationSec : store.breakDurationSec
        }
        guard total > 0 else { return 0 }
        let remaining = remainingSeconds(at: now, store: store)
        return min(1.0, max(0, 1.0 - Double(remaining) / Double(total)))
    }
}
