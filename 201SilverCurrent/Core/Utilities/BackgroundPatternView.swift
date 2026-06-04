import SwiftUI

/// Lightweight background: gradients only (no Canvas — avoids scroll jank).
struct AppBackgroundView<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            AppGradients.screenBackground
            AppGradients.accentGlow
            AppGradients.primaryGlow
            content()
        }
    }
}
