import Foundation

enum TaskCategory: String, Codable, CaseIterable, Identifiable {
    case work
    case personal
    case health
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .work: return "Work"
        case .personal: return "Personal"
        case .health: return "Health"
        case .other: return "Other"
        }
    }
}

enum TaskPriority: Int, Codable, CaseIterable, Identifiable {
    case low = 1
    case medium = 2
    case high = 3

    var id: Int { rawValue }

    var symbolName: String {
        switch self {
        case .low: return "arrow.down"
        case .medium: return "equal"
        case .high: return "arrow.up"
        }
    }

    var label: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

struct TaskItem: Codable, Identifiable, Equatable {
    var id: UUID
    var title: String
    var category: TaskCategory
    var priority: TaskPriority
    var completedAt: Date?
    var dueDate: Date?
    var notes: String
    var tags: [String]
    var isArchived: Bool
    var archivedAt: Date?

    var isCompleted: Bool { completedAt != nil }

    init(
        id: UUID = UUID(),
        title: String,
        category: TaskCategory = .personal,
        priority: TaskPriority = .medium,
        completedAt: Date? = nil,
        dueDate: Date? = nil,
        notes: String = "",
        tags: [String] = [],
        isArchived: Bool = false,
        archivedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.priority = priority
        self.completedAt = completedAt
        self.dueDate = dueDate
        self.notes = notes
        self.tags = tags
        self.isArchived = isArchived
        self.archivedAt = archivedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, title, category, priority, completedAt
        case dueDate, notes, tags, isArchived, archivedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        category = try container.decode(TaskCategory.self, forKey: .category)
        priority = try container.decode(TaskPriority.self, forKey: .priority)
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
        archivedAt = try container.decodeIfPresent(Date.self, forKey: .archivedAt)
    }

    func isOverdue(calendar: Calendar = .current) -> Bool {
        guard !isCompleted, let dueDate else { return false }
        let dueDay = calendar.startOfDay(for: dueDate)
        let today = calendar.startOfDay(for: Date())
        return dueDay < today
    }

    func isDueToday(calendar: Calendar = .current) -> Bool {
        guard !isCompleted, let dueDate else { return false }
        return calendar.isDateInToday(dueDate)
    }
}
