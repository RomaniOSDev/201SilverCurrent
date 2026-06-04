import SwiftUI

enum AppCardElevation {
    /// Scroll lists: gradient + border only, no shadow (60fps friendly).
    case list
    case flat
    case raised
    case hero
}

struct AppCardModifier: ViewModifier {
    var elevation: AppCardElevation = .raised
    var accentBorder: Bool = true

    func body(content: Content) -> some View {
        let radius = cornerRadius
        content
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(borderOverlay(radius: radius))
            .appTopShine(cornerRadius: radius)
            .appDepth(depth)
    }

    private var cornerRadius: CGFloat {
        switch elevation {
        case .list: return 14
        case .flat: return 14
        case .raised: return 16
        case .hero: return 20
        }
    }

    private var depth: AppDepth {
        switch elevation {
        case .list, .flat: return .none
        case .raised: return .medium
        case .hero: return .strong
        }
    }

    @ViewBuilder
    private func borderOverlay(radius: CGFloat) -> some View {
        if accentBorder {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(Color("AppAccent").opacity(borderOpacity), lineWidth: 1)
        }
    }

    private var borderOpacity: Double {
        switch elevation {
        case .list: return 0.18
        case .flat: return 0.2
        case .raised: return 0.24
        case .hero: return 0.3
        }
    }

    @ViewBuilder
    private var cardBackground: some View {
        switch elevation {
        case .list, .flat:
            AppGradients.surface
        case .raised:
            ZStack {
                AppGradients.surface
                AppGradients.primaryGlow
                    .opacity(0.35)
            }
        case .hero:
            AppGradients.hero
        }
    }
}

extension View {
    func appCard(elevation: AppCardElevation = .raised, accentBorder: Bool = true) -> some View {
        modifier(AppCardModifier(elevation: elevation, accentBorder: accentBorder))
    }
}
