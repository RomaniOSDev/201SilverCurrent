import Foundation

struct FocusSessionLogEntry: Codable, Identifiable, Equatable {
    var id: UUID
    var taskId: UUID?
    var completedAt: Date
    var durationMinutes: Int

    init(id: UUID = UUID(), taskId: UUID? = nil, completedAt: Date = Date(), durationMinutes: Int) {
        self.id = id
        self.taskId = taskId
        self.completedAt = completedAt
        self.durationMinutes = durationMinutes
    }
}
