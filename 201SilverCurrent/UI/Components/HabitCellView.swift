import SwiftUI

struct HabitCellView: View {
    let habit: HabitItem
    let streak: Int
    let scheduleText: String
    let statusText: String
    let dueToday: Bool
    let doneToday: Bool
    let weekDays: [Date]
    let isAnimating: Bool
    let onToggle: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                IconBadgeView(symbol: "repeat.circle.fill", size: 48, style: doneToday ? .accent : .primary)
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color("AppPrimary"))
                    Text(scheduleText)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color("AppAccent"))
                    Text(statusText)
                        .font(.caption)
                        .foregroundStyle(doneToday ? Color("AppAccent") : Color("AppTextSecondary"))
                }
                Spacer()
                VStack(spacing: 6) {
                    CheckToggleButton(isOn: doneToday, isEnabled: dueToday, action: onToggle)
                        .scaleEffect(isAnimating ? 1.12 : 1)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                        Text("\(streak)")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(Color("AppAccent"))
                }
            }
            weekTracker
        }
        .padding(16)
        .appCard(elevation: .list)
    }

    private var weekTracker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Last 7 days")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color("AppTextSecondary"))
            HStack(spacing: 0) {
                ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
                    VStack(spacing: 6) {
                        Text(dayLetter(day))
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color("AppTextSecondary"))
                        Circle()
                            .fill(dotColor(for: day))
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(
                                        calendar.isDateInToday(day) ? Color("AppPrimary") : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    }
                    .frame(maxWidth: .infinity)
                    if index < weekDays.count - 1 {
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(12)
        .background(AppGradients.surfaceInset)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func dayLetter(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date).uppercased()
    }

    private func dotColor(for day: Date) -> Color {
        let completed = habit.isCompleted(on: day, calendar: calendar)
        let scheduled = habit.isScheduled(on: day, calendar: calendar)
        if !scheduled { return Color("AppTextSecondary").opacity(0.12) }
        if completed { return Color("AppAccent") }
        if calendar.isDateInToday(day) { return Color("AppTextSecondary").opacity(0.35) }
        if day < calendar.startOfDay(for: Date()) { return Color.red.opacity(0.65) }
        return Color("AppTextSecondary").opacity(0.2)
    }
}
