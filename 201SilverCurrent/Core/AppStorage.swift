import Combine
import Foundation

enum TaskFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case today = "Today"
    case overdue = "Overdue"
    case completed = "Done"
    case archived = "Archive"
}

final class AppDataStore: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let tasks = "tasks"
        static let selectedFilter = "selectedFilter"
        static let lastOpenedDate = "lastOpenedDate"
        static let currentCycle = "currentCycle"
        static let completedSessions = "completedSessions"
        static let focusDurationSec = "focusDurationSec"
        static let breakDurationSec = "breakDurationSec"
        static let habits = "habits"
        static let habitStreaks = "habitStreaks"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let tasksCompleted = "tasksCompleted"
        static let focusSessionsCompleted = "focusSessionsCompleted"
        static let habitCheckIns = "habitCheckIns"
        static let longestStreak = "longestStreak"
        static let totalFocusMinutes = "totalFocusMinutes"
        static let focusPreset = "focusPreset"
        static let taskSearchQuery = "taskSearchQuery"
        static let selectedTagFilter = "selectedTagFilter"
        static let archiveAfterDays = "archiveAfterDays"
        static let quietFocusMode = "quietFocusMode"
        static let activeFocusTaskId = "activeFocusTaskId"
        static let focusSessionLog = "focusSessionLog"
        static let focusMinutesByTaskId = "focusMinutesByTaskId"
        static let weeklyGoalTasksTarget = "weeklyGoalTasksTarget"
        static let weeklyGoalFocusTarget = "weeklyGoalFocusTarget"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let calendar = Calendar.current

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var tasks: [TaskItem] {
        didSet { save(tasks, key: Keys.tasks) }
    }

    @Published var selectedFilter: TaskFilter {
        didSet { defaults.set(selectedFilter.rawValue, forKey: Keys.selectedFilter) }
    }

    @Published var taskSearchQuery: String {
        didSet { defaults.set(taskSearchQuery, forKey: Keys.taskSearchQuery) }
    }

    @Published var selectedTagFilter: String? {
        didSet {
            if let selectedTagFilter {
                defaults.set(selectedTagFilter, forKey: Keys.selectedTagFilter)
            } else {
                defaults.removeObject(forKey: Keys.selectedTagFilter)
            }
        }
    }

    @Published var archiveAfterDays: Int {
        didSet { defaults.set(archiveAfterDays, forKey: Keys.archiveAfterDays) }
    }

    @Published var quietFocusMode: Bool {
        didSet { defaults.set(quietFocusMode, forKey: Keys.quietFocusMode) }
    }

    @Published var activeFocusTaskId: UUID? {
        didSet {
            if let id = activeFocusTaskId {
                defaults.set(id.uuidString, forKey: Keys.activeFocusTaskId)
            } else {
                defaults.removeObject(forKey: Keys.activeFocusTaskId)
            }
        }
    }

    @Published var focusSessionLog: [FocusSessionLogEntry] {
        didSet { save(focusSessionLog, key: Keys.focusSessionLog) }
    }

    @Published var focusMinutesByTaskId: [String: Int] {
        didSet { save(focusMinutesByTaskId, key: Keys.focusMinutesByTaskId) }
    }

    @Published var weeklyGoalTasksTarget: Int {
        didSet { defaults.set(weeklyGoalTasksTarget, forKey: Keys.weeklyGoalTasksTarget) }
    }

    @Published var weeklyGoalFocusTarget: Int {
        didSet { defaults.set(weeklyGoalFocusTarget, forKey: Keys.weeklyGoalFocusTarget) }
    }

    @Published var lastOpenedDate: Date? {
        didSet {
            if let lastOpenedDate {
                defaults.set(lastOpenedDate, forKey: Keys.lastOpenedDate)
            } else {
                defaults.removeObject(forKey: Keys.lastOpenedDate)
            }
        }
    }

    @Published var currentCycle: Int {
        didSet { defaults.set(currentCycle, forKey: Keys.currentCycle) }
    }

    @Published var completedSessions: Int {
        didSet { defaults.set(completedSessions, forKey: Keys.completedSessions) }
    }

    @Published var focusDurationSec: Int {
        didSet { defaults.set(focusDurationSec, forKey: Keys.focusDurationSec) }
    }

    @Published var breakDurationSec: Int {
        didSet { defaults.set(breakDurationSec, forKey: Keys.breakDurationSec) }
    }

    @Published var habits: [HabitItem] {
        didSet {
            save(habits, key: Keys.habits)
            refreshHabitStreaks()
        }
    }

    @Published var habitStreaks: [String: Int] {
        didSet { save(habitStreaks, key: Keys.habitStreaks) }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let lastActivityDate {
                defaults.set(lastActivityDate, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { save(achievementsUnlocked, key: Keys.achievementsUnlocked) }
    }

    @Published var tasksCompleted: Int {
        didSet { defaults.set(tasksCompleted, forKey: Keys.tasksCompleted) }
    }

    @Published var focusSessionsCompleted: Int {
        didSet { defaults.set(focusSessionsCompleted, forKey: Keys.focusSessionsCompleted) }
    }

    @Published var habitCheckIns: Int {
        didSet { defaults.set(habitCheckIns, forKey: Keys.habitCheckIns) }
    }

    @Published var longestStreak: Int {
        didSet { defaults.set(longestStreak, forKey: Keys.longestStreak) }
    }

    @Published var totalFocusMinutes: Int {
        didSet { defaults.set(totalFocusMinutes, forKey: Keys.totalFocusMinutes) }
    }

    @Published var focusPreset: String {
        didSet { defaults.set(focusPreset, forKey: Keys.focusPreset) }
    }

    @Published var pendingAchievementBanner: AchievementDefinition?
    private var achievementQueue: [AchievementDefinition] = []

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        tasks = Self.load([TaskItem].self, key: Keys.tasks, decoder: decoder, defaults: defaults) ?? []
        let filterRaw = defaults.string(forKey: Keys.selectedFilter) ?? TaskFilter.all.rawValue
        selectedFilter = TaskFilter(rawValue: filterRaw) ?? .all
        taskSearchQuery = defaults.string(forKey: Keys.taskSearchQuery) ?? ""
        selectedTagFilter = defaults.string(forKey: Keys.selectedTagFilter)
        archiveAfterDays = defaults.object(forKey: Keys.archiveAfterDays) as? Int ?? 7
        quietFocusMode = defaults.bool(forKey: Keys.quietFocusMode)
        if let taskIdRaw = defaults.string(forKey: Keys.activeFocusTaskId) {
            activeFocusTaskId = UUID(uuidString: taskIdRaw)
        } else {
            activeFocusTaskId = nil
        }
        focusSessionLog = Self.load([FocusSessionLogEntry].self, key: Keys.focusSessionLog, decoder: decoder, defaults: defaults) ?? []
        focusMinutesByTaskId = Self.load([String: Int].self, key: Keys.focusMinutesByTaskId, decoder: decoder, defaults: defaults) ?? [:]
        weeklyGoalTasksTarget = defaults.object(forKey: Keys.weeklyGoalTasksTarget) as? Int ?? 5
        weeklyGoalFocusTarget = defaults.object(forKey: Keys.weeklyGoalFocusTarget) as? Int ?? 3
        lastOpenedDate = defaults.object(forKey: Keys.lastOpenedDate) as? Date
        currentCycle = defaults.object(forKey: Keys.currentCycle) as? Int ?? 1
        completedSessions = defaults.integer(forKey: Keys.completedSessions)
        focusDurationSec = defaults.object(forKey: Keys.focusDurationSec) as? Int ?? 1500
        breakDurationSec = defaults.object(forKey: Keys.breakDurationSec) as? Int ?? 300
        habits = Self.load([HabitItem].self, key: Keys.habits, decoder: decoder, defaults: defaults) ?? []
        habitStreaks = Self.load([String: Int].self, key: Keys.habitStreaks, decoder: decoder, defaults: defaults) ?? [:]
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.load([String: Date].self, key: Keys.achievementsUnlocked, decoder: decoder, defaults: defaults) ?? [:]
        tasksCompleted = defaults.integer(forKey: Keys.tasksCompleted)
        focusSessionsCompleted = defaults.integer(forKey: Keys.focusSessionsCompleted)
        habitCheckIns = defaults.integer(forKey: Keys.habitCheckIns)
        longestStreak = defaults.integer(forKey: Keys.longestStreak)
        totalFocusMinutes = defaults.integer(forKey: Keys.totalFocusMinutes)
        focusPreset = defaults.string(forKey: Keys.focusPreset) ?? "25/5"
        refreshHabitStreaks()
        archiveOldCompletedTasks()
        evaluateAchievements()
    }

    var totalEntriesCreated: Int {
        tasks.filter { !$0.isArchived }.count + habits.count
    }

    var allTags: [String] {
        Array(Set(tasks.flatMap(\.tags))).sorted()
    }

    var weekInterval: (start: Date, end: Date) {
        let end = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -6, to: end) ?? end
        return (start, end)
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
    }

    func recordMeaningfulActivity() {
        let today = calendar.startOfDay(for: Date())
        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            if calendar.isDate(lastDay, inSameDayAs: today) {
                // same day
            } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                      calendar.isDate(lastDay, inSameDayAs: yesterday) {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        lastActivityDate = Date()
        longestStreak = max(longestStreak, streakDays)
        evaluateAchievements()
    }

    func filteredTasks(for filter: TaskFilter? = nil, search: String? = nil, tag: String? = nil) -> [TaskItem] {
        let activeFilter = filter ?? selectedFilter
        let query = (search ?? taskSearchQuery).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let tagFilter = tag ?? selectedTagFilter

        var result = tasks

        switch activeFilter {
        case .all:
            result = result.filter { !$0.isArchived }
        case .active:
            result = result.filter { !$0.isCompleted && !$0.isArchived }
        case .today:
            result = result.filter { task in
                guard !task.isArchived else { return false }
                if let completedAt = task.completedAt {
                    return calendar.isDateInToday(completedAt)
                }
                return task.isDueToday(calendar: calendar)
            }
        case .overdue:
            result = result.filter { !$0.isArchived && $0.isOverdue(calendar: calendar) }
        case .completed:
            result = result.filter { $0.isCompleted && !$0.isArchived }
        case .archived:
            result = result.filter(\.isArchived)
        }

        if let tagFilter, !tagFilter.isEmpty {
            result = result.filter { $0.tags.contains(tagFilter) }
        }

        if !query.isEmpty {
            result = result.filter { task in
                task.title.lowercased().contains(query)
                    || task.notes.lowercased().contains(query)
                    || task.tags.contains { $0.lowercased().contains(query) }
                    || task.category.displayName.lowercased().contains(query)
            }
        }

        return result.sorted { lhs, rhs in
            if lhs.isCompleted != rhs.isCompleted { return !lhs.isCompleted }
            if lhs.isOverdue(calendar: calendar) != rhs.isOverdue(calendar: calendar) {
                return lhs.isOverdue(calendar: calendar)
            }
            switch (lhs.dueDate, rhs.dueDate) {
            case let (l?, r?): return l < r
            case (.some, .none): return true
            case (.none, .some): return false
            case (.none, .none): return lhs.title < rhs.title
            }
        }
    }

    func todayTasks(limit: Int = 3) -> [TaskItem] {
        let active = tasks.filter { !$0.isArchived && !$0.isCompleted }
        let overdue = active.filter { $0.isOverdue(calendar: calendar) }
        let dueToday = active.filter { $0.isDueToday(calendar: calendar) }
        let soon = active
            .filter { task in
                guard let due = task.dueDate else { return false }
                return !task.isOverdue(calendar: calendar) && !task.isDueToday(calendar: calendar) && due >= calendar.startOfDay(for: Date())
            }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        let noDue = active.filter { $0.dueDate == nil }
        var ordered: [TaskItem] = []
        for list in [overdue, dueToday, soon, noDue] {
            for task in list where !ordered.contains(where: { $0.id == task.id }) {
                ordered.append(task)
            }
        }
        return Array(ordered.prefix(limit))
    }

    func todayHabits() -> [HabitItem] {
        habits.filter { $0.isDueToday(calendar: calendar) }
    }

    func addTask(_ task: TaskItem) {
        tasks.append(task)
        recordMeaningfulActivity()
        evaluateAchievements()
    }

    func updateTask(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
    }

    func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
        if activeFocusTaskId == id { activeFocusTaskId = nil }
    }

    func archiveTask(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isArchived = true
        tasks[index].archivedAt = Date()
    }

    func unarchiveTask(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isArchived = false
        tasks[index].archivedAt = nil
    }

    func archiveOldCompletedTasks() {
        let cutoff = calendar.date(byAdding: .day, value: -archiveAfterDays, to: Date()) ?? Date()
        var changed = false
        for index in tasks.indices {
            guard tasks[index].isCompleted,
                  !tasks[index].isArchived,
                  let completedAt = tasks[index].completedAt,
                  completedAt < cutoff else { continue }
            tasks[index].isArchived = true
            tasks[index].archivedAt = Date()
            changed = true
        }
        if changed { tasks = tasks }
    }

    func toggleTaskCompletion(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        if tasks[index].isCompleted {
            tasks[index].completedAt = nil
        } else {
            tasks[index].completedAt = Date()
            tasksCompleted += 1
            recordMeaningfulActivity()
        }
        evaluateAchievements()
    }

    func addHabit(_ habit: HabitItem) {
        habits.append(habit)
        recordMeaningfulActivity()
    }

    func updateHabit(_ habit: HabitItem) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[index] = habit
    }

    func deleteHabit(id: UUID) {
        habits.removeAll { $0.id == id }
        refreshHabitStreaks()
    }

    func toggleHabitToday(id: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return }
        let today = calendar.startOfDay(for: Date())
        guard habits[index].isDueToday(calendar: calendar) else { return }
        if habits[index].isCompleted(on: today, calendar: calendar) {
            habits[index].completedDates.removeAll { calendar.isDate($0, inSameDayAs: today) }
        } else {
            habits[index].completedDates.append(Date())
            habitCheckIns += 1
            recordMeaningfulActivity()
        }
        refreshHabitStreaks()
        evaluateAchievements()
    }

    func completeFocusSession(durationMinutes: Int, taskId: UUID? = nil) {
        let linkedTaskId = taskId ?? activeFocusTaskId
        completedSessions += 1
        focusSessionsCompleted += 1
        totalSessionsCompleted += 1
        totalFocusMinutes += durationMinutes
        totalMinutesUsed += durationMinutes
        let entry = FocusSessionLogEntry(taskId: linkedTaskId, durationMinutes: durationMinutes)
        focusSessionLog.append(entry)
        if let linkedTaskId {
            let key = linkedTaskId.uuidString
            focusMinutesByTaskId[key, default: 0] += durationMinutes
        }
        recordMeaningfulActivity()
        evaluateAchievements()
    }

    func focusMinutes(for taskId: UUID) -> Int {
        focusMinutesByTaskId[taskId.uuidString, default: 0]
    }

    func weeklyReport() -> WeeklyReport {
        let interval = weekInterval
        let tasksDone = tasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            let day = calendar.startOfDay(for: completedAt)
            return day >= interval.start && day <= interval.end
        }.count

        let focusMin = focusSessionLog.filter { entry in
            let day = calendar.startOfDay(for: entry.completedAt)
            return day >= interval.start && day <= interval.end
        }.reduce(0) { $0 + $1.durationMinutes }

        let habitPercent = habitCompletionPercentLast7Days()

        return WeeklyReport(
            tasksCompleted: tasksDone,
            focusMinutes: focusMin,
            habitCompletionPercent: habitPercent,
            periodStart: interval.start,
            periodEnd: interval.end
        )
    }

    func weeklyGoalProgress() -> WeeklyGoalProgress {
        let interval = weekInterval
        let tasksThisWeek = tasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            let day = calendar.startOfDay(for: completedAt)
            return day >= interval.start && day <= interval.end
        }.count
        let focusThisWeek = focusSessionLog.filter { entry in
            let day = calendar.startOfDay(for: entry.completedAt)
            return day >= interval.start && day <= interval.end
        }.count
        return WeeklyGoalProgress(
            tasksCompleted: tasksThisWeek,
            tasksTarget: weeklyGoalTasksTarget,
            focusSessions: focusThisWeek,
            focusTarget: weeklyGoalFocusTarget
        )
    }

    func habitCompletionPercentLast7Days() -> Int {
        guard !habits.isEmpty else { return 0 }
        let interval = weekInterval
        var scheduled = 0
        var completed = 0
        var day = interval.start
        while day <= interval.end {
            for habit in habits where habit.isScheduled(on: day, calendar: calendar) {
                scheduled += 1
                if habit.isCompleted(on: day, calendar: calendar) {
                    completed += 1
                }
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        guard scheduled > 0 else { return 0 }
        return Int((Double(completed) / Double(scheduled) * 100).rounded())
    }

    func refreshHabitStreaks() {
        var streaks: [String: Int] = [:]
        var maxHabitStreak = 0
        for habit in habits {
            let s = habit.streak(calendar: calendar)
            streaks[habit.id.uuidString] = s
            maxHabitStreak = max(maxHabitStreak, s)
        }
        habitStreaks = streaks
        longestStreak = max(longestStreak, maxHabitStreak, streakDays)
        evaluateAchievements()
    }

    func isAchievementUnlocked(_ achievement: AchievementDefinition) -> Bool {
        achievementsUnlocked[achievement.id] != nil
    }

    func evaluateAchievements() {
        for achievement in AchievementDefinition.all where shouldUnlock(achievement) && achievementsUnlocked[achievement.id] == nil {
            achievementsUnlocked[achievement.id] = Date()
            enqueueAchievementBanner(achievement)
        }
    }

    private func shouldUnlock(_ achievement: AchievementDefinition) -> Bool {
        switch achievement.id {
        case "first_task": return tasksCompleted >= 1
        case "focus_starter": return focusSessionsCompleted >= 1
        case "habit_tracker": return habitCheckIns >= 1
        case "streak_initiator": return longestStreak >= 3
        case "getting_going": return tasksCompleted >= 10
        case "power_user": return tasksCompleted >= 50
        case "week_long_habit": return longestStreak >= 7
        case "time_invested": return totalFocusMinutes >= 60
        default: return false
        }
    }

    private func enqueueAchievementBanner(_ achievement: AchievementDefinition) {
        if pendingAchievementBanner == nil {
            pendingAchievementBanner = achievement
        } else {
            achievementQueue.append(achievement)
        }
    }

    func dismissAchievementBanner() {
        if achievementQueue.isEmpty {
            pendingAchievementBanner = nil
        } else {
            pendingAchievementBanner = achievementQueue.removeFirst()
        }
    }

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        hasSeenOnboarding = false
        tasks = []
        selectedFilter = .all
        taskSearchQuery = ""
        selectedTagFilter = nil
        archiveAfterDays = 7
        quietFocusMode = false
        activeFocusTaskId = nil
        focusSessionLog = []
        focusMinutesByTaskId = [:]
        weeklyGoalTasksTarget = 5
        weeklyGoalFocusTarget = 3
        lastOpenedDate = nil
        currentCycle = 1
        completedSessions = 0
        focusDurationSec = 1500
        breakDurationSec = 300
        habits = []
        habitStreaks = [:]
        totalSessionsCompleted = 0
        totalMinutesUsed = 0
        streakDays = 0
        lastActivityDate = nil
        achievementsUnlocked = [:]
        tasksCompleted = 0
        focusSessionsCompleted = 0
        habitCheckIns = 0
        longestStreak = 0
        totalFocusMinutes = 0
        focusPreset = "25/5"
        pendingAchievementBanner = nil
        achievementQueue = []
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func load<T: Decodable>(
        _ type: T.Type,
        key: String,
        decoder: JSONDecoder,
        defaults: UserDefaults
    ) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }
}
