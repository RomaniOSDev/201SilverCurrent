import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        AppBackgroundView {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenHeaderView(
                        title: "Stats",
                        subtitle: "\(unlockedCount) of 8 achievements"
                    )
                    WeeklyReportCard(report: store.weeklyReport())
                    WeeklyGoalsCard(progress: store.weeklyGoalProgress())
                    summaryCard
                    SectionHeaderView(title: "Achievements", subtitle: "Unlock by using the app")
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(AchievementDefinition.all) { achievement in
                            AchievementCellView(
                                achievement: achievement,
                                isUnlocked: store.isAchievementUnlocked(achievement)
                            )
                        }
                    }
                }
                .padding(16)
            }
        }
    }

    private var unlockedCount: Int {
        AchievementDefinition.all.filter { store.isAchievementUnlocked($0) }.count
    }

    private var summaryCard: some View {
        HStack(spacing: 0) {
            summaryMetric(title: "Tasks", value: "\(store.tasksCompleted)", icon: "checkmark.circle.fill")
            Divider().frame(height: 40)
            summaryMetric(title: "Focus", value: "\(store.totalFocusMinutes)m", icon: "timer")
            Divider().frame(height: 40)
            summaryMetric(title: "Streak", value: "\(store.streakDays)d", icon: "flame.fill")
        }
        .padding(.vertical, 16)
        .appCard(elevation: .raised)
    }

    private func summaryMetric(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color("AppAccent"))
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity)
    }
}
