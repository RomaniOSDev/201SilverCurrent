import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(Color("AppTextPrimary"))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .background(AppGradients.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .appTopShine(cornerRadius: 12)
            .appDepth(configuration.isPressed ? .subtle : .medium)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                if pressed { FeedbackManager.lightTap() }
            }
    }
}

struct ScalePressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                if pressed { FeedbackManager.lightTap() }
            }
    }
}
