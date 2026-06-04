import SwiftUI

struct AchievementBannerView: View {
    let achievement: AchievementDefinition
    let onDismiss: () -> Void

    @State private var offset: CGFloat = -120

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundStyle(Color("AppTextPrimary"))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Achievement Unlocked")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(achievement.title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppGradients.hero)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .appTopShine(cornerRadius: 14)
            .appDepth(.medium)
            .padding(.horizontal, 16)
            .offset(y: offset)
            Spacer()
        }
        .onAppear {
            FeedbackManager.achievementUnlocked()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    offset = -120
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    onDismiss()
                }
            }
        }
    }
}
