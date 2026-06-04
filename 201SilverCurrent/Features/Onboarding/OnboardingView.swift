import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var pageIndex = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            step: 1,
            icon: "chart.line.uptrend.xyaxis",
            headline: "Boost Your Productivity",
            description: "Efficiently manage your tasks and routines with ease.",
            illustration: .productivity
        ),
        OnboardingPage(
            step: 2,
            icon: "calendar.badge.clock",
            headline: "Utilize Task Scheduler",
            description: "Organize your tasks with simple taps to maintain focus.",
            illustration: .scheduler
        ),
        OnboardingPage(
            step: 3,
            icon: "flag.checkered",
            headline: "Start Your Journey",
            description: "Create your first task to begin enhancing productivity.",
            illustration: .journey
        )
    ]

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                onboardingHeader
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 8)

                TabView(selection: $pageIndex) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPage(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: pageIndex)

                pageIndicator
                    .padding(.bottom, 20)

                Button(action: advance) {
                    Text(pageIndex == pages.count - 1 ? "Get Started" : "Next")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private var onboardingHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color("AppPrimary"))
                Text("Set up in a few steps")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer(minLength: 12)
            Text("Step \(pageIndex + 1) of \(pages.count)")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppGradients.surfaceInset)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color("AppAccent").opacity(0.28), lineWidth: 1))
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == pageIndex ? AnyShapeStyle(AppGradients.primary) : AnyShapeStyle(Color("AppTextSecondary").opacity(0.25)))
                    .frame(width: index == pageIndex ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: pageIndex)
            }
        }
    }

    private func onboardingPage(_ page: OnboardingPage) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                illustrationPanel(page)
                contentCard(page)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }

    private func illustrationPanel(_ page: OnboardingPage) -> some View {
        ZStack {
            page.illustration.view
                .padding(.vertical, 24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .background(
            ZStack {
                AppGradients.surface
                AppGradients.primaryGlow.opacity(0.5)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color("AppAccent").opacity(0.3), lineWidth: 1)
        )
        .appTopShine(cornerRadius: 20)
        .appDepth(.medium)
    }

    private func contentCard(_ page: OnboardingPage) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                IconBadgeView(symbol: page.icon, size: 48, style: .accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Step \(page.step)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppAccent"))
                    Text(page.headline)
                        .font(.title3.bold())
                        .foregroundStyle(Color("AppPrimary"))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            Text(page.description)
                .font(.body)
                .foregroundStyle(Color("AppTextSecondary"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .appCard(elevation: .raised)
    }

    private func advance() {
        FeedbackManager.lightTap()
        if pageIndex < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                pageIndex += 1
            }
        } else {
            FeedbackManager.success()
            store.completeOnboarding()
        }
    }
}

private struct OnboardingPage {
    let step: Int
    let icon: String
    let headline: String
    let description: String
    let illustration: OnboardingIllustration
}

private enum OnboardingIllustration {
    case productivity
    case scheduler
    case journey

    @ViewBuilder
    var view: some View {
        switch self {
        case .productivity:
            ProductivityShapeIllustration()
        case .scheduler:
            SchedulerShapeIllustration()
        case .journey:
            JourneyShapeIllustration()
        }
    }
}

private struct ProductivityShapeIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppGradients.surfaceInset)
                .frame(width: 168, height: 128)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color("AppAccent").opacity(0.25), lineWidth: 1)
                )
            Path { path in
                path.move(to: CGPoint(x: 40, y: 80))
                path.addLine(to: CGPoint(x: 80, y: 40))
                path.addLine(to: CGPoint(x: 120, y: 60))
                path.addLine(to: CGPoint(x: 160, y: 30))
            }
            .stroke(AppGradients.primarySoft, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            .frame(width: 200, height: 120)
        }
    }
}

private struct SchedulerShapeIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color("AppAccent"), Color("AppPrimary")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 140, height: 140)
            ForEach(0..<8, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppGradients.primary)
                    .frame(width: 8, height: 22)
                    .offset(y: -52)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
            Circle()
                .fill(AppGradients.primary)
                .frame(width: 14, height: 14)
                .appDepth(.subtle)
        }
    }
}

private struct JourneyShapeIllustration: View {
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 20, y: 100))
                path.addQuadCurve(to: CGPoint(x: 180, y: 40), control: CGPoint(x: 100, y: 120))
            }
            .stroke(AppGradients.primarySoft, style: StrokeStyle(lineWidth: 4, lineCap: .round))
            .frame(width: 200, height: 120)

            ZStack {
                Circle()
                    .fill(AppGradients.primary)
                    .frame(width: 52, height: 52)
                Image(systemName: "flag.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            .appTopShine(cornerRadius: 26)
            .appDepth(.subtle)
            .offset(x: 70, y: -30)
        }
    }
}
