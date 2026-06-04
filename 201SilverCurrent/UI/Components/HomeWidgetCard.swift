import SwiftUI

struct HomeHeroBanner: View {
    let greeting: String
    let dateText: String
    let tasksDue: Int
    let habitsDue: Int

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("home_hero")
                .resizable()
                .scaledToFill()
                .frame(height: 168)
                .clipped()

            LinearGradient(
                colors: [Color.clear, Color("AppPrimary").opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(greeting)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(dateText)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                HStack(spacing: 16) {
                    heroPill(icon: "checklist", text: "\(tasksDue) tasks")
                    heroPill(icon: "repeat", text: "\(habitsDue) habits")
                }
            }
            .padding(16)
        }
        .frame(height: 168)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color("AppAccent").opacity(0.35), lineWidth: 1)
        )
        .appTopShine(cornerRadius: 20)
        .appDepth(.strong)
    }

    private func heroPill(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
            Text(text)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(Color("AppTextPrimary"))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.28), Color.white.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(Capsule())
    }
}

struct HomeQuickStatCell: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            IconBadgeView(symbol: icon, size: 36, style: .accent)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .appCard(elevation: .raised)
    }
}

struct HomeFeatureWidget: View {
    let imageName: String
    let title: String
    let subtitle: String
    let metric: String
    let metricLabel: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 88)
                    .clipped()

                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(alignment: .firstTextBaseline) {
                        Text(metric)
                            .font(.title2.bold())
                            .foregroundStyle(Color("AppAccent"))
                        Text(metricLabel)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                        Spacer()
                        Text(actionTitle)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("AppPrimary"))
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
                .padding(12)
            }
            .appCard(elevation: .raised)
        }
        .buttonStyle(ScalePressButtonStyle())
    }
}

struct HomeWeeklyWidget: View {
    let progress: WeeklyGoalProgress
    let report: WeeklyReport
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    SectionHeaderView(title: "This Week", subtitle: "Your momentum")
                    Spacer()
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title3)
                        .foregroundStyle(Color("AppAccent"))
                }
                HStack(spacing: 12) {
                    weekMetric(value: "\(report.tasksCompleted)", label: "Tasks done")
                    weekMetric(value: "\(report.focusMinutes)m", label: "Focus")
                    weekMetric(value: "\(report.habitCompletionPercent)%", label: "Habits")
                }
                VStack(spacing: 10) {
                    progressLine(
                        title: "Task goal",
                        current: progress.tasksCompleted,
                        target: progress.tasksTarget,
                        fraction: progress.tasksProgress
                    )
                    progressLine(
                        title: "Focus goal",
                        current: progress.focusSessions,
                        target: progress.focusTarget,
                        fraction: progress.focusProgress
                    )
                }
            }
            .padding(16)
            .appCard(elevation: .raised)
        }
        .buttonStyle(ScalePressButtonStyle())
    }

    private func weekMetric(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(AppGradients.surfaceInset)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func progressLine(title: String, current: Int, target: Int, fraction: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppPrimary"))
                Spacer()
                Text("\(current)/\(target)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color("AppAccent"))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color("AppAccent").opacity(0.18))
                    Capsule()
                        .fill(AppGradients.primarySoft)
                        .frame(width: max(6, geo.size.width * fraction))
                }
            }
            .frame(height: 8)
        }
    }
}

struct HomeTodayStrip: View {
    let title: String
    let items: [HomeStripItem]
    let emptyMessage: String
    let onToggle: (UUID) -> Void

    struct HomeStripItem: Identifiable {
        let id: UUID
        let title: String
        let subtitle: String?
        let isDone: Bool
        let isEnabled: Bool
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: title, subtitle: "\(items.count) items")
            if items.isEmpty {
                Text(emptyMessage)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appCard(elevation: .raised)
            } else {
                VStack(spacing: 8) {
                    ForEach(items) { item in
                        CompactListCell(
                            title: item.title,
                            subtitle: item.subtitle,
                            isDone: item.isDone,
                            isEnabled: item.isEnabled,
                            onToggle: { onToggle(item.id) }
                        )
                    }
                }
            }
        }
    }
}
