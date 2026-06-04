import SwiftUI

struct TaskCellView: View {
    let task: TaskItem
    let isPulsing: Bool
    let onToggle: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            priorityRail
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color("AppPrimary"))
                            .strikethrough(task.isCompleted)
                            .lineLimit(2)
                        if !task.notes.isEmpty {
                            Text(task.notes)
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .lineLimit(2)
                        }
                    }
                    Spacer(minLength: 8)
                    CheckToggleButton(isOn: task.isCompleted, action: onToggle)
                }
                metadataRow
                if !task.tags.isEmpty {
                    tagsRow
                }
            }
        }
        .padding(14)
        .appCard(elevation: .list, accentBorder: !task.isCompleted)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("AppAccent").opacity(isPulsing ? 0.2 : 0))
        )
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onTapGesture(perform: onTap)
    }

    private var priorityRail: some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(priorityGradient)
            .frame(width: 4)
            .padding(.vertical, 4)
    }

    private var priorityGradient: LinearGradient {
        switch task.priority {
        case .high: return AppGradients.primary
        case .medium:
            return LinearGradient(
                colors: [Color("AppAccent"), Color("AppAccent").opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .low:
            return LinearGradient(
                colors: [Color("AppTextSecondary").opacity(0.35), Color("AppTextSecondary").opacity(0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var metadataRow: some View {
        HStack(spacing: 6) {
            StatusPill(text: task.category.displayName, style: .primary)
            if task.isOverdue() && !task.isCompleted {
                StatusPill(text: "Overdue", style: .danger)
            } else if task.isDueToday() && !task.isCompleted {
                StatusPill(text: "Today", style: .accent)
            } else if let due = task.dueDate, !task.isCompleted {
                StatusPill(text: due.formatted(date: .abbreviated, time: .omitted), style: .muted)
            }
            HStack(spacing: 2) {
                Image(systemName: task.priority.symbolName)
                Text(task.priority.label)
            }
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Color("AppAccent"))
        }
    }

    private var tagsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(task.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color("AppAccent"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("AppAccent").opacity(0.12))
                        .clipShape(Capsule())
                }
            }
        }
    }
}

struct StatusPill: View {
    let text: String
    let style: PillStyle

    enum PillStyle {
        case primary, accent, muted, danger
    }

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .lineLimit(1)
            .foregroundStyle(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background { background }
            .clipShape(Capsule())
    }

    private var foreground: Color {
        switch style {
        case .primary, .accent: return Color("AppTextPrimary")
        case .muted: return Color("AppTextSecondary")
        case .danger: return Color.red.opacity(0.9)
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary: AppGradients.primary
        case .accent:
            LinearGradient(
                colors: [Color("AppAccent"), Color("AppAccent").opacity(0.75)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .muted:
            Color("AppTextSecondary").opacity(0.15)
        case .danger:
            Color.red.opacity(0.12)
        }
    }
}
