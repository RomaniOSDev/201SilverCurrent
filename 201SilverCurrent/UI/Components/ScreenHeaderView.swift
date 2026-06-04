import SwiftUI

struct ScreenHeaderView: View {
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var actionIcon: String = "plus"
    var onAction: (() -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color("AppPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer(minLength: 8)
            if let actionTitle, let onAction {
                Button(action: onAction) {
                    HStack(spacing: 6) {
                        Image(systemName: actionIcon)
                        Text(actionTitle)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

struct InlineNavHeaderView: View {
    let title: String
    var leadingTitle: String?
    var trailingTitle: String?
    var onLeading: (() -> Void)?
    var onTrailing: (() -> Void)?

    var body: some View {
        HStack {
            if let leadingTitle, let onLeading {
                headerButton(leadingTitle, action: onLeading)
            } else {
                Color.clear.frame(width: 72, height: 44)
            }
            Spacer()
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
            Spacer()
            if let trailingTitle, let onTrailing {
                headerButton(trailingTitle, action: onTrailing)
            } else {
                Color.clear.frame(width: 72, height: 44)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    private func headerButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("AppPrimary"))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(AppGradients.surface)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color("AppAccent").opacity(0.28), lineWidth: 1))
                .appDepth(.subtle)
        }
        .frame(minHeight: 44)
    }
}
