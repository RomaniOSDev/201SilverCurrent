import SwiftUI

enum FocusHabitsSection: String, CaseIterable {
    case focus = "Focus"
    case habits = "Habits"
}

struct FocusHabitsHubView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var section: FocusHabitsSection = .focus

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                ForEach(FocusHabitsSection.allCases, id: \.self) { item in
                    FilterChip(
                        title: item.rawValue,
                        isSelected: section == item,
                        action: {
                            FeedbackManager.lightTap(quietMode: store.quietFocusMode)
                            withAnimation(.easeInOut(duration: 0.3)) {
                                section = item
                            }
                        }
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Group {
                switch section {
                case .focus:
                    FocusView()
                case .habits:
                    HabitsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
