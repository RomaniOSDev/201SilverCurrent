import Foundation

enum DataExporter {
    static func makeJSON(store: AppDataStore) -> Data? {
        let payload = ExportPayload(
            exportedAt: Date(),
            tasks: store.tasks,
            habits: store.habits,
            focusSessionLog: store.focusSessionLog,
            focusMinutesByTaskId: store.focusMinutesByTaskId,
            stats: ExportStats(
                tasksCompleted: store.tasksCompleted,
                totalFocusMinutes: store.totalFocusMinutes,
                streakDays: store.streakDays
            )
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(payload)
    }

    static func makeCSV(store: AppDataStore) -> String {
        var lines: [String] = []
        lines.append("Type,Title,Category,Due Date,Completed,Tags,Notes,Archived")
        let formatter = ISO8601DateFormatter()
        for task in store.tasks {
            let due = task.dueDate.map { formatter.string(from: $0) } ?? ""
            let completed = task.completedAt.map { formatter.string(from: $0) } ?? ""
            let tags = task.tags.joined(separator: ";")
            let notes = task.notes.replacingOccurrences(of: "\"", with: "\"\"")
            lines.append(
                "Task,\"\(task.title.replacingOccurrences(of: "\"", with: "\"\""))\",\(task.category.rawValue),\(due),\(completed),\(tags),\"\(notes)\",\(task.isArchived)"
            )
        }
        for habit in store.habits {
            lines.append("Habit,\"\(habit.title.replacingOccurrences(of: "\"", with: "\"\""))\",\(habit.schedule.rawValue),,,,,")
        }
        lines.append("")
        lines.append("Focus Task ID,Minutes")
        for (taskId, minutes) in store.focusMinutesByTaskId.sorted(by: { $0.key < $1.key }) {
            lines.append("\(taskId),\(minutes)")
        }
        return lines.joined(separator: "\n")
    }
}

private struct ExportPayload: Encodable {
    let exportedAt: Date
    let tasks: [TaskItem]
    let habits: [HabitItem]
    let focusSessionLog: [FocusSessionLogEntry]
    let focusMinutesByTaskId: [String: Int]
    let stats: ExportStats
}

private struct ExportStats: Encodable {
    let tasksCompleted: Int
    let totalFocusMinutes: Int
    let streakDays: Int
}
