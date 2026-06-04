import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showResetAlert = false
    @State private var showExportSheet = false
    @State private var exportItems: [Any] = []

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        AppBackgroundView {
            ScrollView {
                VStack(spacing: 16) {
                    ScreenHeaderView(title: "Settings", subtitle: "Preferences & data")

                    statsHeroCard

                    FeatureCardView(icon: "slider.horizontal.3", title: "Preferences") {
                        Toggle("Quiet focus mode", isOn: $store.quietFocusMode)
                            .tint(Color("AppAccent"))
                        preferenceStepper(
                            "Archive after \(store.archiveAfterDays) days",
                            value: $store.archiveAfterDays,
                            range: 1...90
                        )
                        preferenceStepper(
                            "Weekly goal: \(store.weeklyGoalTasksTarget) tasks",
                            value: $store.weeklyGoalTasksTarget,
                            range: 1...30
                        )
                        preferenceStepper(
                            "Weekly goal: \(store.weeklyGoalFocusTarget) sessions",
                            value: $store.weeklyGoalFocusTarget,
                            range: 1...20
                        )
                    }

                    VStack(spacing: 0) {
                        SettingsRowCell(icon: "star.fill", title: "Rate Us") {
                            FeedbackManager.lightTap(quietMode: store.quietFocusMode)
                            rateApp()
                        }
                        cellDivider
                        SettingsRowCell(icon: "hand.raised.fill", title: "Privacy") {
                            FeedbackManager.lightTap(quietMode: store.quietFocusMode)
                            openPrivacyPolicy()
                        }
                        cellDivider
                        SettingsRowCell(icon: "doc.text", title: "Terms") {
                            FeedbackManager.lightTap(quietMode: store.quietFocusMode)
                            openTerms()
                        }
                    }
                    .appCard(elevation: .flat)

                    VStack(spacing: 0) {
                        SettingsRowCell(icon: "square.and.arrow.up", title: "Export JSON", subtitle: "Full backup") {
                            exportJSON()
                        }
                        cellDivider
                        SettingsRowCell(icon: "tablecells", title: "Export CSV", subtitle: "Spreadsheet friendly") {
                            exportCSV()
                        }
                    }
                    .appCard(elevation: .flat)

                    SettingsRowCell(
                        icon: "trash.fill",
                        title: "Reset All Data",
                        subtitle: "Cannot be undone",
                        showsChevron: false,
                        isDestructive: true
                    ) {
                        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
                        showResetAlert = true
                    }
                    .appCard(elevation: .flat)

                    Text("Version \(appVersion)")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                }
                .padding(16)
            }
        }
        .sheet(isPresented: $showExportSheet) {
            ShareSheet(items: exportItems)
        }
        .alert("Reset All Data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {
                FeedbackManager.lightTap(quietMode: store.quietFocusMode)
            }
            Button("Reset", role: .destructive) {
                store.resetAllData()
                FeedbackManager.warning(quietMode: store.quietFocusMode)
            }
        } message: {
            Text("This will permanently delete all tasks, habits, focus progress, and achievements.")
        }
    }

    private var statsHeroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your Stats")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
            HStack(spacing: 12) {
                statTile(value: "\(store.totalEntriesCreated)", label: "Entries")
                statTile(value: "\(store.totalMinutesUsed)", label: "Minutes")
                statTile(value: "\(store.streakDays)", label: "Streak")
            }
        }
        .padding(18)
        .appCard(elevation: .hero, accentBorder: false)
    }

    private func statTile(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(Color("AppTextPrimary"))
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.16), Color.white.opacity(0.06)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var cellDivider: some View {
        Divider().padding(.leading, 58)
    }

    private func preferenceStepper(_ label: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        Stepper(label, value: value, in: range)
            .font(.subheadline)
            .foregroundStyle(Color("AppPrimary"))
    }

    private func exportJSON() {
        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
        guard let data = DataExporter.makeJSON(store: store) else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("zenith_export.json")
        try? data.write(to: url)
        exportItems = [url]
        showExportSheet = true
    }

    private func exportCSV() {
        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
        let csv = DataExporter.makeCSV(store: store)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("zenith_export.csv")
        try? csv.write(to: url, atomically: true, encoding: .utf8)
        exportItems = [url]
        showExportSheet = true
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func openPrivacyPolicy() {
        if let url = AppExternalLinks.privacyPolicy.url {
            UIApplication.shared.open(url)
        }
    }

    private func openTerms() {
        if let url = AppExternalLinks.termsOfUse.url {
            UIApplication.shared.open(url)
        }
    }
}
