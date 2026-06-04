import Combine
import Foundation

final class HabitsViewModel: ObservableObject {
    @Published var showingAddSheet = false
    @Published var newHabitTitle = ""
    @Published var schedule: HabitSchedule = .everyDay
    @Published var selectedWeekdays: Set<Int> = [2, 3, 4, 5, 6]
    @Published var validationShake = 0
    @Published var errorMessage: String?
    @Published var animatingCheckID: UUID?
    @Published var showSuccessFlash = false

    static let weekdayLabels: [(Int, String)] = [
        (1, "Sun"), (2, "Mon"), (3, "Tue"), (4, "Wed"),
        (5, "Thu"), (6, "Fri"), (7, "Sat")
    ]

    func openAdd() {
        FeedbackManager.lightTap()
        newHabitTitle = ""
        schedule = .everyDay
        selectedWeekdays = [2, 3, 4, 5, 6]
        errorMessage = nil
        showingAddSheet = true
    }

    func saveHabit(store: AppDataStore) -> Bool {
        let trimmed = newHabitTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            FeedbackManager.warning(quietMode: store.quietFocusMode)
            validationShake += 1
            errorMessage = "Please enter a habit name."
            return false
        }
        if schedule == .custom && selectedWeekdays.isEmpty {
            FeedbackManager.warning(quietMode: store.quietFocusMode)
            errorMessage = "Select at least one day."
            return false
        }
        let habit = HabitItem(
            title: trimmed,
            schedule: schedule,
            customWeekdays: schedule == .custom ? Array(selectedWeekdays).sorted() : []
        )
        store.addHabit(habit)
        FeedbackManager.success(quietMode: store.quietFocusMode)
        showSuccessFlash = true
        showingAddSheet = false
        newHabitTitle = ""
        errorMessage = nil
        return true
    }

    func toggleToday(_ habit: HabitItem, store: AppDataStore) {
        guard habit.isDueToday() else { return }
        let wasDone = habit.isCompleted(on: Date())
        store.toggleHabitToday(id: habit.id)
        if !wasDone {
            FeedbackManager.habitComplete(quietMode: store.quietFocusMode)
            FeedbackManager.success(quietMode: store.quietFocusMode)
            animatingCheckID = habit.id
            showSuccessFlash = true
        } else {
            FeedbackManager.mediumAction(quietMode: store.quietFocusMode)
        }
    }

    func delete(_ habit: HabitItem, store: AppDataStore) {
        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
        store.deleteHabit(id: habit.id)
    }
}
