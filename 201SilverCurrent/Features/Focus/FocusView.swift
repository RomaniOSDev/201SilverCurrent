import SwiftUI

struct FocusView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = FocusViewModel()
    @State private var emptyStopwatchPulse = false

    private var activeTasks: [TaskItem] {
        store.tasks.filter { !$0.isArchived && !$0.isCompleted }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                InlineNavHeaderView(
                    title: "Focus",
                    leadingTitle: "Settings",
                    trailingTitle: "Stats",
                    onLeading: {
                        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
                        viewModel.showSettings = true
                    },
                    onTrailing: {
                        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
                        viewModel.showStatistics = true
                    }
                )
                linkedTaskCard
                timerCard
                controlButtons
                cycleInfoCard
                presetPicker
            }
            .padding(.bottom, 24)
        }
        .onAppear { viewModel.bind(store: store) }
        .onChange(of: scenePhase) { phase in
            if phase != .active, viewModel.timerState == .running || viewModel.timerState == .onBreak {
                viewModel.pause(store: store)
            }
        }
        .sheet(isPresented: $viewModel.showSettings) {
            FocusSettingsSheet().environmentObject(store)
        }
        .sheet(isPresented: $viewModel.showStatistics) {
            FocusStatisticsSheet().environmentObject(store)
        }
        .overlay {
            if viewModel.showSuccessFlash {
                SuccessFlashView(isVisible: $viewModel.showSuccessFlash)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
            viewModel.stop(store: store)
        }
    }

    private var linkedTaskCard: some View {
        FeatureCardView(icon: "link", title: "Linked Task", subtitle: "Track focus time per task") {
            if activeTasks.isEmpty {
                Text("Create an active task to link focus sessions.")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            } else {
                Picker("Task", selection: Binding(
                    get: { store.activeFocusTaskId },
                    set: { newValue in
                        FeedbackManager.lightTap(quietMode: store.quietFocusMode)
                        store.activeFocusTaskId = newValue
                    }
                )) {
                    Text("None").tag(Optional<UUID>.none)
                    ForEach(activeTasks) { task in
                        Text(task.title).tag(Optional(task.id))
                    }
                }
                .pickerStyle(.menu)
                .tint(Color("AppPrimary"))
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var timerCard: some View {
        VStack(spacing: 12) {
            if viewModel.showsEmptyPlaceholder {
                emptyTimerState
            } else {
                TimelineView(.periodic(from: .now, by: 1.0)) { context in
                    let date = context.date
                    FocusTimerRing(
                        progress: viewModel.progress(at: date, store: store),
                        remaining: viewModel.remainingSeconds(at: date, store: store),
                        isFocusPhase: viewModel.isFocusPhase,
                        glowActive: viewModel.glowActive
                    )
                    .task(id: date) {
                        viewModel.handleTimelineTick(
                            now: date,
                            store: store,
                            isActive: scenePhase == .active
                        )
                    }
                }
                .id(viewModel.timerState)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .appCard(elevation: .raised)
        .padding(.horizontal, 16)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 1.2)
                .onEnded { _ in viewModel.resetSessionData(store: store) }
        )
    }

    private var emptyTimerState: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 3, dash: [8, 6]))
                    .foregroundStyle(Color("AppAccent").opacity(0.45))
                    .frame(width: 160, height: 160)
                Image(systemName: "stopwatch")
                    .font(.system(size: 44))
                    .foregroundStyle(Color("AppAccent"))
                    .opacity(emptyStopwatchPulse ? 0.5 : 1)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: emptyStopwatchPulse)
                    .onAppear { emptyStopwatchPulse = true }
            }
            Text("Stay focused and productive!")
                .font(.headline)
                .foregroundStyle(Color("AppPrimary"))
            Text("Tap Start Focus to begin your first session.")
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
        }
    }

    private var controlButtons: some View {
        HStack(spacing: 10) {
            focusControlButton("Start", icon: "play.fill", primary: true) {
                viewModel.start(store: store)
            }
            .disabled(viewModel.timerState == .running || viewModel.timerState == .onBreak)

            focusControlButton("Pause", icon: "pause.fill", primary: false) {
                viewModel.pause(store: store)
            }
            .disabled(viewModel.timerState != .running && viewModel.timerState != .onBreak)
            .opacity(viewModel.timerState == .running || viewModel.timerState == .onBreak ? 1 : 0.45)

            focusControlButton("Stop", icon: "stop.fill", primary: false) {
                viewModel.stop(store: store)
            }
            .disabled(viewModel.timerState == .idle)
            .opacity(viewModel.timerState == .idle ? 0.45 : 1)
        }
        .padding(.horizontal, 16)
    }

    private func focusControlButton(
        _ title: String,
        icon: String,
        primary: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                Text(title)
                    .font(.caption.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(primary ? Color("AppTextPrimary") : Color("AppPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                Group {
                    if primary {
                        AppGradients.primary
                    } else {
                        AppGradients.surface
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .appTopShine(cornerRadius: 14)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color("AppAccent").opacity(primary ? 0 : 0.28), lineWidth: 1)
            )
            .appDepth(primary ? .medium : .none)
        }
        .buttonStyle(ScalePressButtonStyle())
    }

    private var cycleInfoCard: some View {
        HStack(spacing: 0) {
            cycleStat(title: viewModel.cycleLabel, subtitle: "Cycle")
            Divider().frame(height: 36)
            cycleStat(title: "\(store.completedSessions)", subtitle: "Sessions")
            Divider().frame(height: 36)
            cycleStat(
                title: viewModel.isFocusPhase ? "Focus" : "Break",
                subtitle: "Phase"
            )
        }
        .padding(.vertical, 14)
        .appCard(elevation: .raised)
        .padding(.horizontal, 16)
    }

    private func cycleStat(title: String, subtitle: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity)
    }

    private var presetPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Templates", subtitle: "Quick duration presets")
                .padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(FocusPreset.allCases) { preset in
                        FilterChip(
                            title: preset.rawValue,
                            isSelected: (FocusPreset(rawValue: store.focusPreset) ?? .short) == preset,
                            action: { viewModel.applyPreset(preset, store: store) }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

private struct FocusTimerRing: View {
    let progress: Double
    let remaining: Int
    let isFocusPhase: Bool
    let glowActive: Bool

    private var timeText: String {
        String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("AppAccent").opacity(0.15), lineWidth: 16)
                .frame(width: 220, height: 220)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(AppGradients.primary, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 220, height: 220)
                .animation(.easeInOut(duration: 0.3), value: progress)
            Circle()
                .fill(Color("AppPrimary").opacity(glowActive ? 0.2 : 0.06))
                .frame(width: 176, height: 176)
                .shadow(color: Color("AppAccent").opacity(glowActive ? 0.7 : 0), radius: glowActive ? 24 : 0)
            VStack(spacing: 8) {
                Text(timeText)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("AppPrimary"))
                    .monospacedDigit()
                StatusPill(text: isFocusPhase ? "Focus" : "Break", style: .accent)
            }
        }
    }
}
