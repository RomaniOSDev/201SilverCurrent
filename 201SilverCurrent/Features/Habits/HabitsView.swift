import SwiftUI

struct HabitsView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = HabitsViewModel()

    private let calendar = Calendar.current

    private var weekDays: [Date] {
        (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -6 + offset, to: calendar.startOfDay(for: Date()))
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                ScreenHeaderView(
                    title: "Habits",
                    subtitle: "\(store.habits.count) routines",
                    actionTitle: nil
                )
                if store.habits.isEmpty {
                    EmptyStateView(
                        icon: "checklist",
                        title: "Build habits",
                        message: "No habits yet! Tap + to add your first routine.",
                        actionTitle: "Add Habit",
                        onAction: { viewModel.openAdd() }
                    )
                } else {
                    List {
                        ForEach(store.habits) { habit in
                            habitCell(habit)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.delete(habit, store: store)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        viewModel.toggleToday(habit, store: store)
                                    } label: {
                                        Label("Complete", systemImage: "checkmark")
                                    }
                                    .tint(Color("AppPrimary"))
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            FloatingActionButton(icon: "plus") {
                viewModel.openAdd()
            }
        }
        .sheet(isPresented: $viewModel.showingAddSheet) {
            addHabitSheet
        }
        .overlay {
            if viewModel.showSuccessFlash {
                SuccessFlashView(isVisible: $viewModel.showSuccessFlash)
            }
        }
    }

    private func habitCell(_ habit: HabitItem) -> some View {
        let dueToday = habit.isDueToday(calendar: calendar)
        let doneToday = habit.isCompleted(on: Date(), calendar: calendar)
        let streak = store.habitStreaks[habit.id.uuidString] ?? habit.streak(calendar: calendar)

        return HabitCellView(
            habit: habit,
            streak: streak,
            scheduleText: scheduleLabel(habit),
            statusText: statusLabel(dueToday: dueToday, doneToday: doneToday),
            dueToday: dueToday,
            doneToday: doneToday,
            weekDays: weekDays,
            isAnimating: viewModel.animatingCheckID == habit.id,
            onToggle: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    viewModel.toggleToday(habit, store: store)
                }
            }
        )
        .onChange(of: viewModel.animatingCheckID) { id in
            guard id != nil else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                viewModel.animatingCheckID = nil
            }
        }
    }

    private func scheduleLabel(_ habit: HabitItem) -> String {
        switch habit.schedule {
        case .everyDay: return "Every day"
        case .weekdays: return "Weekdays"
        case .custom:
            return HabitsViewModel.weekdayLabels
                .filter { habit.customWeekdaySet.contains($0.0) }
                .map(\.1)
                .joined(separator: ", ")
        }
    }

    private func statusLabel(dueToday: Bool, doneToday: Bool) -> String {
        if !dueToday { return "Not scheduled today" }
        return doneToday ? "Completed today" : "Tap to complete"
    }

    private var addHabitSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    FeatureCardView(icon: "sparkles", title: "New Habit", subtitle: "Name your routine") {
                        TextField("Habit name", text: $viewModel.newHabitTitle)
                            .shake(trigger: viewModel.validationShake)
                            .padding(12)
                            .background(Color("AppBackground"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        if let error = viewModel.errorMessage {
                            Text(error).font(.caption).foregroundStyle(.red)
                        }
                    }
                    FeatureCardView(icon: "calendar", title: "Schedule") {
                        Picker("Repeat", selection: $viewModel.schedule) {
                            ForEach(HabitSchedule.allCases) { item in
                                Text(item.displayName).tag(item)
                            }
                        }
                        .pickerStyle(.segmented)
                        if viewModel.schedule == .custom {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 52))], spacing: 8) {
                                ForEach(HabitsViewModel.weekdayLabels, id: \.0) { weekday, label in
                                    FilterChip(
                                        title: label,
                                        isSelected: viewModel.selectedWeekdays.contains(weekday),
                                        action: {
                                            if viewModel.selectedWeekdays.contains(weekday) {
                                                viewModel.selectedWeekdays.remove(weekday)
                                            } else {
                                                viewModel.selectedWeekdays.insert(weekday)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color("AppBackground"))
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
                        viewModel.showingAddSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { _ = viewModel.saveHabit(store: store) }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
