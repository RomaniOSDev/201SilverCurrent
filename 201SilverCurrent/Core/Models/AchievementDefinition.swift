import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_task",
            title: "First Task",
            description: "Completed your first task.",
            iconName: "checkmark.circle.fill"
        ),
        AchievementDefinition(
            id: "focus_starter",
            title: "Focus Starter",
            description: "Completed one focus session.",
            iconName: "timer"
        ),
        AchievementDefinition(
            id: "habit_tracker",
            title: "Habit Tracker",
            description: "Logged one habit check-in.",
            iconName: "calendar.badge.checkmark"
        ),
        AchievementDefinition(
            id: "streak_initiator",
            title: "Streak Initiator",
            description: "Achieved a 3-day streak in habits.",
            iconName: "flame.fill"
        ),
        AchievementDefinition(
            id: "getting_going",
            title: "Getting Going",
            description: "Reached 10 items.",
            iconName: "star.fill"
        ),
        AchievementDefinition(
            id: "power_user",
            title: "Power User",
            description: "Reached 50 items.",
            iconName: "bolt.fill"
        ),
        AchievementDefinition(
            id: "week_long_habit",
            title: "Week-Long Habit",
            description: "Used the app 7 days in a row.",
            iconName: "calendar"
        ),
        AchievementDefinition(
            id: "time_invested",
            title: "Time Invested",
            description: "Spent 60 minutes total in the app.",
            iconName: "clock.fill"
        )
    ]
}
