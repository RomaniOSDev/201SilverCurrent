import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var onAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 32)
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color("AppAccent").opacity(0.25), Color("AppAccent").opacity(0.05)],
                            center: .center,
                            startRadius: 8,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color("AppAccent").opacity(0.5), Color("AppPrimary").opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 120, height: 120)
                Image(systemName: icon)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color("AppAccent"))
            }
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(Color("AppPrimary"))
            Text(message)
                .font(.body)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
            if let actionTitle, let onAction {
                Button(actionTitle, action: onAction)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 40)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(AppGradients.primary)
                    .frame(width: 58, height: 58)
                Image(systemName: icon)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            .appTopShine(cornerRadius: 29)
            .appDepth(.medium)
        }
        .buttonStyle(ScalePressButtonStyle())
        .padding(24)
        .accessibilityLabel("Add")
    }
}

struct SectionHeaderView: View {
    let title: String
    var subtitle: String?
    var trailing: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color("AppPrimary"))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
            }
        }
    }
}
