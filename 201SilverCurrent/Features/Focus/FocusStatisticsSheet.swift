import SwiftUI

struct FocusStatisticsSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    private var taskFocusRows: [(TaskItem, Int)] {
        store.tasks.compactMap { task -> (TaskItem, Int)? in
            let minutes = store.focusMinutes(for: task.id)
            guard minutes > 0 else { return nil }
            return (task, minutes)
        }.sorted { $0.1 > $1.1 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    statCard(icon: "checkmark.circle", title: "Completed Sessions", value: "\(store.completedSessions)")
                    statCard(icon: "clock", title: "Total Focus Minutes", value: "\(store.totalFocusMinutes)")
                    statCard(icon: "arrow.triangle.2.circlepath", title: "Current Cycle", value: "\(store.currentCycle)")
                    HStack(spacing: 12) {
                        statCard(icon: "hourglass", title: "Focus", value: "\(store.focusDurationSec / 60)m", compact: true)
                        statCard(icon: "cup.and.saucer", title: "Break", value: "\(store.breakDurationSec / 60)m", compact: true)
                    }
                    if !taskFocusRows.isEmpty {
                        FeatureCardView(icon: "chart.bar", title: "Minutes per Task") {
                            ForEach(taskFocusRows, id: \.0.id) { task, minutes in
                                HStack {
                                    Text(task.title)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(Color("AppPrimary"))
                                        .lineLimit(1)
                                    Spacer()
                                    Text("\(minutes) min")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(Color("AppAccent"))
                                }
                                .padding(.vertical, 6)
                                if task.id != taskFocusRows.last?.0.id {
                                    Divider()
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color("AppBackground"))
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
                        dismiss()
                    }
                }
            }
        }
    }

    private func statCard(icon: String, title: String, value: String, compact: Bool = false) -> some View {
        HStack(spacing: 12) {
            IconBadgeView(symbol: icon, size: compact ? 36 : 44, style: .accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(compact ? .caption : .subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(value)
                    .font(compact ? .title3.bold() : .title.bold())
                    .foregroundStyle(Color("AppPrimary"))
            }
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .appCard(elevation: .flat)
    }
}
