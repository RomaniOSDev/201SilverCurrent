import SwiftUI

struct AchievementCellView: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        isUnlocked
                            ? Color("AppAccent").opacity(0.2)
                            : Color("AppTextSecondary").opacity(0.1)
                    )
                    .frame(width: 56, height: 56)
                Image(systemName: achievement.iconName)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(isUnlocked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.4))
            }
            Text(achievement.title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(3)
            if isUnlocked {
                StatusPill(text: "Unlocked", style: .accent)
            }
        }
        .padding(14)
        .frame(minHeight: 168)
        .frame(maxWidth: .infinity)
        .appCard(elevation: .raised, accentBorder: isUnlocked)
        .opacity(isUnlocked ? 1 : 0.82)
    }
}

struct HeroGreetingCard: View {
    let greeting: String
    let subtitle: String
    var tasksCount: Int
    var habitsCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(greeting)
                        .font(.title.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                IconBadgeView(symbol: "sun.max.fill", size: 52, style: .muted)
            }
            HStack(spacing: 12) {
                miniStat(value: "\(tasksCount)", label: "Tasks")
                miniStat(value: "\(habitsCount)", label: "Habits")
            }
        }
        .padding(18)
        .appCard(elevation: .hero, accentBorder: false)
    }

    private func miniStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(Color("AppTextPrimary"))
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct CompactListCell: View {
    let title: String
    var subtitle: String?
    let isDone: Bool
    var isEnabled: Bool = true
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            CheckToggleButton(isOn: isDone, isEnabled: isEnabled, action: onToggle)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color("AppPrimary"))
                    .strikethrough(isDone)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer()
        }
        .padding(14)
        .appCard(elevation: .list)
    }
}
