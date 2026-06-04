import SwiftUI

struct TaskEditorView: View {
    @EnvironmentObject private var store: AppDataStore
    @ObservedObject var viewModel: TasksViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var category: TaskCategory = .personal
    @State private var priority: TaskPriority = .medium
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var notes: String = ""
    @State private var tagsText: String = ""
    @State private var validationShake = 0
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    FeatureCardView(icon: "pencil", title: "Task", subtitle: viewModel.editingTask == nil ? "New item" : "Edit item") {
                        TextField("Title", text: $title)
                            .shake(trigger: validationShake)
                            .padding(12)
                            .background(Color("AppBackground"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        if let errorMessage {
                            Text(errorMessage).font(.caption).foregroundStyle(.red)
                        }
                    }
                    FeatureCardView(icon: "calendar", title: "Due Date") {
                        Toggle("Set deadline", isOn: $hasDueDate)
                            .tint(Color("AppAccent"))
                        if hasDueDate {
                            DatePicker("Due", selection: $dueDate, displayedComponents: .date)
                        }
                    }
                    FeatureCardView(icon: "note.text", title: "Notes") {
                        TextField("Description", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .padding(12)
                            .background(Color("AppBackground"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    FeatureCardView(icon: "tag", title: "Tags") {
                        TextField("work, urgent", text: $tagsText)
                            .padding(12)
                            .background(Color("AppBackground"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    FeatureCardView(icon: "folder", title: "Category") {
                        Picker("Category", selection: $category) {
                            ForEach(TaskCategory.allCases) { cat in
                                Text(cat.displayName).tag(cat)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    FeatureCardView(icon: "flag", title: "Priority") {
                        Picker("Priority", selection: $priority) {
                            ForEach(TaskPriority.allCases) { p in
                                Label(p.label, systemImage: p.symbolName).tag(p)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(16)
            }
            .background(Color("AppBackground"))
            .navigationTitle(viewModel.editingTask == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveTask() }
                }
            }
            .onAppear { loadTask() }
        }
    }

    private func loadTask() {
        guard let task = viewModel.editingTask else { return }
        title = task.title
        category = task.category
        priority = task.priority
        hasDueDate = task.dueDate != nil
        dueDate = task.dueDate ?? Date()
        notes = task.notes
        tagsText = task.tags.joined(separator: ", ")
    }

    private var parsedTags: [String] {
        tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func saveTask() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            FeedbackManager.warning(quietMode: store.quietFocusMode)
            validationShake += 1
            errorMessage = "Please enter a task title."
            return
        }
        errorMessage = nil
        if viewModel.save(
            title: trimmed,
            category: category,
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            tags: parsedTags,
            store: store
        ) {
            dismiss()
        }
    }
}
