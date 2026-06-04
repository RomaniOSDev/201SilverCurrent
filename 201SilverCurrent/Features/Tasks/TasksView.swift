import SwiftUI

struct TasksView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = TasksViewModel()

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                VStack(spacing: 0) {
                    ScreenHeaderView(
                        title: "Tasks",
                        subtitle: "\(viewModel.filteredTasks(store: store).count) items",
                        actionTitle: "Add",
                        actionIcon: "plus",
                        onAction: { viewModel.openAdd(store: store) }
                    )
                    AppSearchField(text: $store.taskSearchQuery, placeholder: "Search tasks, notes, tags…")
                    FilterChipRow(
                        items: TaskFilter.allCases,
                        title: { $0.rawValue },
                        isSelected: { store.selectedFilter == $0 },
                        onSelect: { viewModel.setFilter($0, store: store) }
                    )
                    tagFilterRow
                    content
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showingEditor) {
                TaskEditorView(viewModel: viewModel)
                    .environmentObject(store)
            }
            .onAppear {
                viewModel.bind(store: store)
                store.lastOpenedDate = Date()
                store.archiveOldCompletedTasks()
            }
            .overlay(alignment: .bottomTrailing) {
                FloatingActionButton(icon: "plus") {
                    viewModel.openAdd(store: store)
                }
            }
            .overlay {
                if viewModel.showSuccessFlash {
                    SuccessFlashView(isVisible: $viewModel.showSuccessFlash)
                }
            }
        }
    }

    @ViewBuilder
    private var tagFilterRow: some View {
        let tags = store.allTags
        if !tags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All tags",
                        isSelected: store.selectedTagFilter == nil,
                        action: { viewModel.setTagFilter(nil, store: store) }
                    )
                    ForEach(tags, id: \.self) { tag in
                        FilterChip(
                            title: "#\(tag)",
                            isSelected: store.selectedTagFilter == tag,
                            action: { viewModel.setTagFilter(tag, store: store) }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    private var content: some View {
        let items = viewModel.filteredTasks(store: store)
        if items.isEmpty {
            EmptyStateView(
                icon: "tray.fill",
                title: "Nothing here",
                message: emptyMessage,
                actionTitle: store.selectedFilter == .all ? "Add Task" : nil,
                onAction: store.selectedFilter == .all ? { viewModel.openAdd(store: store) } : nil
            )
        } else {
            List {
                ForEach(items) { task in
                    TaskCellView(
                        task: task,
                        isPulsing: viewModel.pulsingTaskID == task.id,
                        onToggle: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                viewModel.toggleComplete(task, store: store)
                            }
                        },
                        onTap: { viewModel.openEdit(task, store: store) }
                    )
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .contextMenu { taskContextMenu(task) }
                    .swipeActions(edge: .trailing) { trailingActions(task) }
                    .swipeActions(edge: .leading) { leadingActions(task) }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private var emptyMessage: String {
        switch store.selectedFilter {
        case .archived: return "No archived tasks."
        case .overdue: return "No overdue tasks."
        case .today: return "Nothing due today."
        default: return "No tasks yet. Tap Add to create your first task."
        }
    }

    @ViewBuilder
    private func taskContextMenu(_ task: TaskItem) -> some View {
        Button("Edit") { viewModel.openEdit(task, store: store) }
        if task.isArchived {
            Button("Unarchive") { store.unarchiveTask(id: task.id) }
        } else {
            Button("Archive") { viewModel.archive(task, store: store) }
        }
        Button("Delete", role: .destructive) { viewModel.delete(task, store: store) }
    }

    @ViewBuilder
    private func trailingActions(_ task: TaskItem) -> some View {
        Button(role: .destructive) { viewModel.delete(task, store: store) } label: {
            Label("Delete", systemImage: "trash")
        }
        if !task.isArchived {
            Button { viewModel.archive(task, store: store) } label: {
                Label("Archive", systemImage: "archivebox")
            }
            .tint(Color("AppAccent"))
        }
        Button { viewModel.openEdit(task, store: store) } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(Color("AppPrimary"))
    }

    @ViewBuilder
    private func leadingActions(_ task: TaskItem) -> some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                viewModel.toggleComplete(task, store: store)
            }
        } label: {
            Label(task.isCompleted ? "Undo" : "Done", systemImage: "checkmark")
        }
        .tint(Color("AppPrimary"))
    }
}
