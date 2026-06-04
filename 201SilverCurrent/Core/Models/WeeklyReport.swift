import Foundation

struct WeeklyReport {
    let tasksCompleted: Int
    let focusMinutes: Int
    let habitCompletionPercent: Int
    let periodStart: Date
    let periodEnd: Date
}

struct WeeklyGoalProgress {
    let tasksCompleted: Int
    let tasksTarget: Int
    let focusSessions: Int
    let focusTarget: Int

    var tasksProgress: Double {
        guard tasksTarget > 0 else { return 0 }
        return min(1.0, Double(tasksCompleted) / Double(tasksTarget))
    }

    var focusProgress: Double {
        guard focusTarget > 0 else { return 0 }
        return min(1.0, Double(focusSessions) / Double(focusTarget))
    }
}
