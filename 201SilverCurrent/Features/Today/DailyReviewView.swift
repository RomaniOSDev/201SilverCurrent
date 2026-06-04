import SwiftUI

struct DailyReviewView: View {
    @EnvironmentObject private var store: AppDataStore

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 18 { return "Good Afternoon" }
        return "Good Evening"
    }

    var body: some View {
        AppBackgroundView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HeroGreetingCard(
                        greeting: greeting,
                        subtitle: "Your plan for today",
                        tasksCount: store.todayTasks(limit: 3).count,
                        habitsCount: store.todayHabits().count
                    )
                    tasksSection
                    habitsSection
                }
                .padding(16)
                .padding(.bottom, 8)
            }
        }
        .onAppear { store.archiveOldCompletedTasks() }
    }

    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Top Tasks", subtitle: "Up to 3 priorities", trailing: "Tasks")
            let todayTasks = store.todayTasks(limit: 3)
            if todayTasks.isEmpty {
                EmptyStateView(
                    icon: "checkmark.circle",
                    title: "All clear",
                    message: "No active tasks. Add one in the Tasks tab."
                )
                .frame(height: 200)
            } else {
                ForEach(todayTasks) { task in
                    CompactListCell(
                        title: task.title,
                        subtitle: dueSubtitle(task),
                        isDone: task.isCompleted,
                        onToggle: { toggleTask(task) }
                    )
                }
            }
        }
    }

    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Today's Habits", subtitle: "Scheduled for today")
            let dueHabits = store.todayHabits()
            if dueHabits.isEmpty {
                EmptyStateView(
                    icon: "calendar",
                    title: "Rest day",
                    message: "No habits scheduled for today."
                )
                .frame(height: 180)
            } else {
                ForEach(dueHabits) { habit in
                    let done = habit.isCompleted(on: Date())
                    CompactListCell(
                        title: habit.title,
                        subtitle: done ? "Completed" : "Tap to log",
                        isDone: done,
                        onToggle: { toggleHabit(habit, wasDone: done) }
                    )
                }
            }
        }
    }

    private func toggleTask(_ task: TaskItem) {
        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            let wasDone = task.isCompleted
            store.toggleTaskCompletion(id: task.id)
            if !wasDone {
                FeedbackManager.taskComplete(quietMode: store.quietFocusMode)
            }
        }
    }

    private func toggleHabit(_ habit: HabitItem, wasDone: Bool) {
        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
        store.toggleHabitToday(id: habit.id)
        if !wasDone {
            FeedbackManager.habitComplete(quietMode: store.quietFocusMode)
        }
    }

    private func dueSubtitle(_ task: TaskItem) -> String? {
        if task.isOverdue() { return "Overdue" }
        if let due = task.dueDate {
            if Calendar.current.isDateInToday(due) { return "Due today" }
            return "Due \(due.formatted(date: .abbreviated, time: .omitted))"
        }
        return nil
    }
}
