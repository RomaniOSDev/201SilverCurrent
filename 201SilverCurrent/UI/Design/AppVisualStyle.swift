import SwiftUI

/// Centralized gradients and depth — one shadow per view max for scroll performance.
enum AppGradients {
    static var primary: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primarySoft: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppPrimary").opacity(0.9),
                Color("AppAccent").opacity(0.75)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var hero: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent").opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var surface: LinearGradient {
        LinearGradient(
            colors: [Color("AppSurface"), Color("AppBackground").opacity(0.35)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var surfaceInset: LinearGradient {
        LinearGradient(
            colors: [Color("AppBackground").opacity(0.5), Color("AppSurface")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var screenBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppBackground"),
                Color("AppSurface").opacity(0.6),
                Color("AppBackground")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentGlow: RadialGradient {
        RadialGradient(
            colors: [Color("AppAccent").opacity(0.14), Color.clear],
            center: .topTrailing,
            startRadius: 8,
            endRadius: 220
        )
    }

    static var primaryGlow: RadialGradient {
        RadialGradient(
            colors: [Color("AppPrimary").opacity(0.1), Color.clear],
            center: .bottomLeading,
            startRadius: 12,
            endRadius: 260
        )
    }
}

enum AppDepth {
    case none
    case subtle
    case medium
    case strong

    var radius: CGFloat {
        switch self {
        case .none: return 0
        case .subtle: return 5
        case .medium: return 10
        case .strong: return 16
        }
    }

    var y: CGFloat {
        switch self {
        case .none: return 0
        case .subtle: return 2
        case .medium: return 5
        case .strong: return 8
        }
    }

    var opacity: Double {
        switch self {
        case .none: return 0
        case .subtle: return 0.07
        case .medium: return 0.12
        case .strong: return 0.18
        }
    }
}

struct AppDepthShadowModifier: ViewModifier {
    let depth: AppDepth

    func body(content: Content) -> some View {
        content.shadow(
            color: Color("AppPrimary").opacity(depth.opacity),
            radius: depth.radius,
            y: depth.y
        )
    }
}

extension View {
    func appDepth(_ depth: AppDepth) -> some View {
        modifier(AppDepthShadowModifier(depth: depth))
    }

    /// Top-edge highlight for volume (cheap stroke gradient, no blur).
    func appTopShine(cornerRadius: CGFloat) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.45),
                            Color.white.opacity(0.08),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
    }
}
