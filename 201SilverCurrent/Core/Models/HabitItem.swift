import Foundation

struct HabitItem: Codable, Identifiable, Equatable {
    var id: UUID
    var title: String
    var completedDates: [Date]
    var schedule: HabitSchedule
    /// Weekdays 1=Sunday … 7=Saturday when schedule == .custom
    var customWeekdays: [Int]

    init(
        id: UUID = UUID(),
        title: String,
        completedDates: [Date] = [],
        schedule: HabitSchedule = .everyDay,
        customWeekdays: [Int] = []
    ) {
        self.id = id
        self.title = title
        self.completedDates = completedDates
        self.schedule = schedule
        self.customWeekdays = customWeekdays
    }

    enum CodingKeys: String, CodingKey {
        case id, title, completedDates, schedule, customWeekdays
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        completedDates = try container.decodeIfPresent([Date].self, forKey: .completedDates) ?? []
        schedule = try container.decodeIfPresent(HabitSchedule.self, forKey: .schedule) ?? .everyDay
        customWeekdays = try container.decodeIfPresent([Int].self, forKey: .customWeekdays) ?? []
    }

    var customWeekdaySet: Set<Int> {
        Set(customWeekdays)
    }

    func isScheduled(on date: Date, calendar: Calendar = .current) -> Bool {
        schedule.isScheduled(on: date, customWeekdays: customWeekdaySet, calendar: calendar)
    }

    func isCompleted(on day: Date, calendar: Calendar = .current) -> Bool {
        completedDates.contains { calendar.isDate($0, inSameDayAs: day) }
    }

    func isDueToday(calendar: Calendar = .current) -> Bool {
        isScheduled(on: Date(), calendar: calendar)
    }

    func streak(calendar: Calendar = .current) -> Int {
        var streak = 0
        var check = calendar.startOfDay(for: Date())
        for _ in 0..<365 {
            if isScheduled(on: check, calendar: calendar) {
                if isCompleted(on: check, calendar: calendar) {
                    streak += 1
                } else if !calendar.isDateInToday(check) {
                    break
                } else {
                    break
                }
            }
            guard let previous = calendar.date(byAdding: .day, value: -1, to: check) else { break }
            check = previous
        }
        return streak
    }
}
