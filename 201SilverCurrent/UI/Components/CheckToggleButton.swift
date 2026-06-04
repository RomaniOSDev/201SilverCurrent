import SwiftUI

struct CheckToggleButton: View {
    let isOn: Bool
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(
                        isOn ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.45),
                        lineWidth: 2.5
                    )
                    .frame(width: 30, height: 30)
                if isOn {
                    Circle()
                        .fill(AppGradients.primary)
                        .frame(width: 30, height: 30)
                        .appDepth(.subtle)
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                }
            }
            .frame(width: 44, height: 44)
            .opacity(isEnabled ? 1 : 0.35)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

struct IconBadgeView: View {
    let symbol: String
    var size: CGFloat = 44
    var style: IconBadgeStyle = .accent

    enum IconBadgeStyle {
        case accent
        case primary
        case muted
    }

    var body: some View {
        ZStack {
            badgeCircle
                .frame(width: size, height: size)
            Image(systemName: symbol)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(foreground)
        }
    }

    @ViewBuilder
    private var badgeCircle: some View {
        switch style {
        case .accent:
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color("AppAccent").opacity(0.28), Color("AppAccent").opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        case .primary:
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color("AppPrimary").opacity(0.2), Color("AppPrimary").opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        case .muted:
            Circle()
                .fill(Color("AppTextSecondary").opacity(0.15))
        }
    }

    private var foreground: Color {
        switch style {
        case .accent: return Color("AppAccent")
        case .primary: return Color("AppPrimary")
        case .muted: return Color("AppTextSecondary")
        }
    }
}
