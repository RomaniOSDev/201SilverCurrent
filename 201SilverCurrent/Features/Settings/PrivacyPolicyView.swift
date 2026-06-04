import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var markdownContent = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                if let attributed = try? AttributedString(markdown: markdownContent) {
                    Text(attributed)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .tint(Color("AppAccent"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                } else {
                    Text(markdownContent)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(16)
                }
            }
            .background(Color("AppPrimary"))
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        FeedbackManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .onAppear {
                markdownContent = loadPrivacyPolicy()
            }
        }
    }

    private func loadPrivacyPolicy() -> String {
        guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            return "# Privacy Policy\nContent unavailable."
        }
        return text
    }
}
