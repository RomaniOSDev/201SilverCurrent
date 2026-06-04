import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppDataStore
    var onNavigate: (MainTab) -> Void

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 18 { return "Good Afternoon" }
        return "Good Evening"
    }

    private var dateText: String {
        Date().formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    private var overdueCount: Int {
        store.tasks.filter { !$0.isArchived && $0.isOverdue() }.count
    }

    private var focusPresetLabel: String {
        let minutes = store.focusDurationSec / 60
        return "\(minutes) min session"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                HomeHeroBanner(
                    greeting: greeting,
                    dateText: dateText,
                    tasksDue: store.todayTasks(limit: 99).count,
                    habitsDue: store.todayHabits().count
                )

                quickStatsRow

                widgetGrid

                HomeWeeklyWidget(
                    progress: store.weeklyGoalProgress(),
                    report: store.weeklyReport(),
                    action: { navigate(.achievements) }
                )

                todayTasksStrip
                todayHabitsStrip
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .onAppear {
            store.archiveOldCompletedTasks()
        }
    }

    private var quickStatsRow: some View {
        HStack(spacing: 10) {
            HomeQuickStatCell(
                icon: "flame.fill",
                value: "\(store.streakDays)",
                label: "Day streak"
            )
            HomeQuickStatCell(
                icon: "checkmark.seal.fill",
                value: "\(store.weeklyReport().tasksCompleted)",
                label: "Done this week"
            )
            HomeQuickStatCell(
                icon: "clock.fill",
                value: "\(store.totalFocusMinutes)",
                label: "Focus minutes"
            )
        }
    }

    private var widgetGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            HomeFeatureWidget(
                imageName: "widget_focus",
                title: "Focus",
                subtitle: focusPresetLabel,
                metric: "\(store.completedSessions)",
                metricLabel: "sessions",
                actionTitle: "Start"
            ) {
                navigate(.focusHabits)
            }

            HomeFeatureWidget(
                imageName: "widget_tasks",
                title: "Tasks",
                subtitle: overdueCount > 0 ? "\(overdueCount) overdue" : "Stay on track",
                metric: "\(store.tasks.filter { !$0.isArchived && !$0.isCompleted }.count)",
                metricLabel: "active",
                actionTitle: "Open"
            ) {
                navigate(.tasks)
            }

            HomeFeatureWidget(
                imageName: "widget_habits",
                title: "Habits",
                subtitle: "Today's routines",
                metric: habitsMetricText,
                metricLabel: "done",
                actionTitle: "Log"
            ) {
                navigate(.focusHabits)
            }

            addTaskWidget
        }
    }

    private var habitsDoneToday: Int {
        store.todayHabits().filter { $0.isCompleted(on: Date()) }.count
    }

    private var habitsMetricText: String {
        let due = store.todayHabits().count
        guard due > 0 else { return "0" }
        return "\(habitsDoneToday)/\(due)"
    }

    private var addTaskWidget: some View {
        Button {
            FeedbackManager.lightTap(quietMode: store.quietFocusMode)
            navigate(.tasks)
        } label: {
            VStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("AppPrimary"), Color("AppAccent")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("Quick Add")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("AppPrimary"))
                Text("New task")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 28)
            .appCard(elevation: .raised)
        }
        .buttonStyle(ScalePressButtonStyle())
    }

    private var todayTasksStrip: some View {
        HomeTodayStrip(
            title: "Priority Tasks",
            items: store.todayTasks(limit: 3).map { task in
                HomeTodayStrip.HomeStripItem(
                    id: task.id,
                    title: task.title,
                    subtitle: taskSubtitle(task),
                    isDone: task.isCompleted,
                    isEnabled: true
                )
            },
            emptyMessage: "No priority tasks. Add one from Tasks.",
            onToggle: { id in toggleTask(id: id) }
        )
    }

    private var todayHabitsStrip: some View {
        HomeTodayStrip(
            title: "Habits Today",
            items: store.todayHabits().map { habit in
                let done = habit.isCompleted(on: Date())
                return HomeTodayStrip.HomeStripItem(
                    id: habit.id,
                    title: habit.title,
                    subtitle: done ? "Completed" : "Tap to complete",
                    isDone: done,
                    isEnabled: true
                )
            },
            emptyMessage: "No habits scheduled for today.",
            onToggle: { id in toggleHabit(id: id) }
        )
    }

    private func navigate(_ tab: MainTab) {
        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
        onNavigate(tab)
    }

    private func taskSubtitle(_ task: TaskItem) -> String? {
        if task.isOverdue() { return "Overdue" }
        if task.isDueToday() { return "Due today" }
        if let due = task.dueDate {
            return due.formatted(date: .abbreviated, time: .omitted)
        }
        return nil
    }

    private func toggleTask(id: UUID) {
        guard let task = store.tasks.first(where: { $0.id == id }) else { return }
        let wasDone = task.isCompleted
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            store.toggleTaskCompletion(id: id)
            if !wasDone {
                FeedbackManager.taskComplete(quietMode: store.quietFocusMode)
                FeedbackManager.success(quietMode: store.quietFocusMode)
            }
        }
    }

    private func toggleHabit(id: UUID) {
        guard let habit = store.habits.first(where: { $0.id == id }) else { return }
        let wasDone = habit.isCompleted(on: Date())
        store.toggleHabitToday(id: id)
        if !wasDone {
            FeedbackManager.habitComplete(quietMode: store.quietFocusMode)
            FeedbackManager.success(quietMode: store.quietFocusMode)
        }
    }
}
