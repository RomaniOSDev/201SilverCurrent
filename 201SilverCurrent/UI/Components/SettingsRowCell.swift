import SwiftUI

struct SettingsRowCell: View {
    let icon: String
    let title: String
    var subtitle: String?
    var showsChevron: Bool = true
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                IconBadgeView(
                    symbol: icon,
                    size: 40,
                    style: isDestructive ? .muted : .accent
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(isDestructive ? Color.red.opacity(0.9) : Color("AppPrimary"))
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                Spacer()
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
        }
    }
}

struct StatMetricCell: View {
    let icon: String
    let title: String
    let value: String
    var inverted: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            IconBadgeView(symbol: icon, size: 36, style: inverted ? .muted : .accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(inverted ? Color("AppTextSecondary") : Color("AppTextSecondary"))
                Text(value)
                    .font(.title3.bold())
                    .foregroundStyle(inverted ? Color("AppTextPrimary") : Color("AppPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct FeatureCardView<Content: View>: View {
    let icon: String
    let title: String
    var subtitle: String?
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                IconBadgeView(symbol: icon, size: 36, style: .primary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
            }
            content()
        }
        .padding(16)
        .appCard(elevation: .flat)
    }
}
