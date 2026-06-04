import SwiftUI

enum MainTab: Int, CaseIterable {
    case home
    case tasks
    case focusHabits
    case achievements
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .tasks: return "Tasks"
        case .focusHabits: return "Focus"
        case .achievements: return "Stats"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .tasks: return "checklist"
        case .focusHabits: return "timer"
        case .achievements: return "star.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var selectedTab: MainTab = .home

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                tabContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .overlay(alignment: .top) {
            if let achievement = store.pendingAchievementBanner {
                AchievementBannerView(achievement: achievement) {
                    store.dismissAchievementBanner()
                }
                .zIndex(10)
            }
        }
        .onChange(of: store.tasksCompleted) { _ in store.evaluateAchievements() }
        .onChange(of: store.focusSessionsCompleted) { _ in store.evaluateAchievements() }
        .onChange(of: store.habitCheckIns) { _ in store.evaluateAchievements() }
        .onChange(of: store.longestStreak) { _ in store.evaluateAchievements() }
        .onChange(of: store.totalFocusMinutes) { _ in store.evaluateAchievements() }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeView { tab in
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = tab
                }
            }
        case .tasks: TasksView()
        case .focusHabits: FocusHabitsHubView()
        case .achievements: AchievementsView()
        case .settings: SettingsView()
        }
    }
}

struct CustomTabBar: View {
    @EnvironmentObject private var store: AppDataStore
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 6) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            ZStack {
                AppGradients.surface
                LinearGradient(
                    colors: [Color("AppSurface"), Color("AppBackground").opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .appDepth(.subtle)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color("AppAccent").opacity(0.25)),
            alignment: .top
        )
    }

    private func tabButton(_ tab: MainTab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            FeedbackManager.lightTap(quietMode: store.quietFocusMode)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(AppGradients.primary)
                            .frame(width: 44, height: 30)
                            .appDepth(.subtle)
                    }
                    Image(systemName: tab.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                }
                Text(tab.title)
                    .font(.system(size: 10, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(isSelected ? Color("AppPrimary") : Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(ScalePressButtonStyle())
        .frame(minHeight: 48)
    }
}
