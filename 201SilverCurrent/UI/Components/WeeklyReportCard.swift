import SwiftUI

struct WeeklyReportCard: View {
    let report: WeeklyReport

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Report")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Last 7 days")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                IconBadgeView(symbol: "chart.bar.fill", size: 40, style: .muted)
            }
            HStack(spacing: 10) {
                metricBlock(title: "Tasks", value: "\(report.tasksCompleted)", icon: "checkmark.seal.fill")
                metricBlock(title: "Focus", value: "\(report.focusMinutes)m", icon: "brain.head.profile")
                metricBlock(title: "Habits", value: "\(report.habitCompletionPercent)%", icon: "percent")
            }
        }
        .padding(18)
        .appCard(elevation: .hero, accentBorder: false)
    }

    private func metricBlock(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppTextSecondary"))
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(AppGradients.surfaceInset)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct WeeklyGoalsCard: View {
    let progress: WeeklyGoalProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Weekly Goals", subtitle: "Track your momentum")
            goalRow(
                icon: "checklist",
                title: "Complete \(progress.tasksTarget) tasks",
                current: progress.tasksCompleted,
                target: progress.tasksTarget,
                fraction: progress.tasksProgress
            )
            goalRow(
                icon: "timer",
                title: "Finish \(progress.focusTarget) focus sessions",
                current: progress.focusSessions,
                target: progress.focusTarget,
                fraction: progress.focusProgress
            )
        }
        .padding(16)
        .appCard(elevation: .raised)
    }

    private func goalRow(
        icon: String,
        title: String,
        current: Int,
        target: Int,
        fraction: Double
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                IconBadgeView(symbol: icon, size: 32, style: .accent)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppPrimary"))
                Spacer()
                Text("\(current)/\(target)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppAccent"))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color("AppAccent").opacity(0.18))
                    Capsule()
                        .fill(AppGradients.primarySoft)
                        .frame(width: max(8, geo.size.width * fraction))
                }
            }
            .frame(height: 10)
        }
    }
}
