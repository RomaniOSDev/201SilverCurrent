import Foundation

enum HabitSchedule: String, Codable, CaseIterable, Identifiable {
    case everyDay
    case weekdays
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .everyDay: return "Every day"
        case .weekdays: return "Weekdays"
        case .custom: return "Selected days"
        }
    }

    /// Calendar weekday: 1 = Sunday … 7 = Saturday
    func isScheduled(on date: Date, customWeekdays: Set<Int>, calendar: Calendar = .current) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        switch self {
        case .everyDay:
            return true
        case .weekdays:
            return (2...6).contains(weekday)
        case .custom:
            return customWeekdays.contains(weekday)
        }
    }
}
