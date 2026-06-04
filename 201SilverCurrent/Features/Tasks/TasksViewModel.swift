import Combine
import Foundation

final class TasksViewModel: ObservableObject {
    @Published var showingEditor = false
    @Published var editingTask: TaskItem?
    @Published var showSuccessFlash = false
    @Published var pulsingTaskID: UUID?

    private weak var store: AppDataStore?

    func bind(store: AppDataStore) {
        self.store = store
    }

    func filteredTasks(store: AppDataStore) -> [TaskItem] {
        store.filteredTasks()
    }

    func setFilter(_ filter: TaskFilter, store: AppDataStore) {
        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
        store.selectedFilter = filter
    }

    func setTagFilter(_ tag: String?, store: AppDataStore) {
        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
        store.selectedTagFilter = tag
    }

    func openAdd(store: AppDataStore) {
        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
        editingTask = nil
        showingEditor = true
    }

    func openEdit(_ task: TaskItem, store: AppDataStore) {
        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
        editingTask = task
        showingEditor = true
    }

    func toggleComplete(_ task: TaskItem, store: AppDataStore) {
        let wasCompleted = task.isCompleted
        store.toggleTaskCompletion(id: task.id)
        if !wasCompleted {
            FeedbackManager.taskComplete(quietMode: store.quietFocusMode)
            FeedbackManager.success(quietMode: store.quietFocusMode)
            pulsingTaskID = task.id
            showSuccessFlash = true
            store.archiveOldCompletedTasks()
        } else {
            FeedbackManager.mediumAction(quietMode: store.quietFocusMode)
        }
    }

    func delete(_ task: TaskItem, store: AppDataStore) {
        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
        store.deleteTask(id: task.id)
    }

    func archive(_ task: TaskItem, store: AppDataStore) {
        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
        store.archiveTask(id: task.id)
    }

    func save(
        title: String,
        category: TaskCategory,
        priority: TaskPriority,
        dueDate: Date?,
        notes: String,
        tags: [String],
        store: AppDataStore
    ) -> Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        if var existing = editingTask {
            existing.title = trimmed
            existing.category = category
            existing.priority = priority
            existing.dueDate = dueDate
            existing.notes = notes
            existing.tags = tags
            store.updateTask(existing)
        } else {
            store.addTask(TaskItem(
                title: trimmed,
                category: category,
                priority: priority,
                dueDate: dueDate,
                notes: notes,
                tags: tags
            ))
        }
        FeedbackManager.success(quietMode: store.quietFocusMode)
        showSuccessFlash = true
        showingEditor = false
        editingTask = nil
        return true
    }
}
