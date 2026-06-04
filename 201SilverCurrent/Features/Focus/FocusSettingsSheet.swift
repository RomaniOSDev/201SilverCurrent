import SwiftUI

struct FocusSettingsSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    @State private var focusMinutes: Double = 25
    @State private var breakMinutes: Double = 5

    var body: some View {
        NavigationStack {
            Form {
                Section("Focus Duration") {
                    Stepper("\(Int(focusMinutes)) min", value: $focusMinutes, in: 5...120, step: 5)
                }
                Section("Break Duration") {
                    Stepper("\(Int(breakMinutes)) min", value: $breakMinutes, in: 1...30, step: 1)
                }
                Section("Feedback") {
                    Toggle("Quiet mode (haptics only)", isOn: $store.quietFocusMode)
                    Text("When enabled, phase completion uses vibration without system sounds.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Section("Task Archive") {
                    Stepper("Archive completed after \(store.archiveAfterDays) days", value: $store.archiveAfterDays, in: 1...90)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("AppBackground"))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.focusDurationSec = Int(focusMinutes) * 60
                        store.breakDurationSec = Int(breakMinutes) * 60
                        store.focusPreset = FocusPreset.custom.rawValue
                        FeedbackManager.success(quietMode: store.quietFocusMode)
                        dismiss()
                    }
                }
            }
            .onAppear {
                focusMinutes = Double(store.focusDurationSec / 60)
                breakMinutes = Double(store.breakDurationSec / 60)
            }
        }
    }
}
