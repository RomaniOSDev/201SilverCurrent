import SwiftUI

struct SuccessFlashView: View {
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color("AppAccent"))
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isVisible = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isVisible = false
                        }
                    }
                }
        }
    }
}

struct PulseHighlightModifier: ViewModifier {
    @Binding var isPulsing: Bool

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("AppAccent").opacity(isPulsing ? 0.25 : 0))
            )
            .onChange(of: isPulsing) { pulsing in
                guard pulsing else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isPulsing = false
                }
            }
    }
}

extension View {
    func pulseHighlight(_ isPulsing: Binding<Bool>) -> some View {
        modifier(PulseHighlightModifier(isPulsing: isPulsing))
    }
}
