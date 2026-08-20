import SwiftUI

struct ClassicGameView: View {
    @StateObject private var game = ClassicGameModel()
    @StateObject private var stats = StatsStore()
    @Environment(\.scenePhase) private var scenePhase

    @State private var showHowTo = false
    @State private var showSettings = false
    @State private var flashOpacity = 0.0
    @State private var feedbackText = ""
    @State private var feedbackScale = 0.7
    @State private var recordedGameOver = false
    @State private var isNewBest = false

    var body: some View {
        ZStack {
            background

            switch game.phase {
            case .menu:
                menu
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            case .playing:
                gameplay
                    .transition(.opacity)
            case .gameOver:
                gameOver
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }

            Color.white
                .opacity(flashOpacity)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            if showHowTo {
                howToOverlay
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.36, dampingFraction: 0.86), value: game.phase)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { game.resume() } else { game.pause() }
        }
        .onChange(of: game.feedbackID) { _, _ in handleFeedback() }
        .sheet(isPresented: $showSettings) { settingsSheet }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.025, green: 0.03, blue: 0.07), Color(red: 0.06, green: 0.025, blue: 0.11), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(0.12))
                .frame(width: 360, height: 360)
                .blur(radius: 100)
                .offset(x: -150, y: -260)

            Circle()
                .fill(Color.purple.opacity(0.12))
                .frame(width: 340, height: 340)
                .blur(radius: 110)
                .offset(x: 150, y: 280)
        }
    }

    private var menu: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 46, height: 46)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityLabel("Settings")
            }
            .padding(.horizontal, 22)
            .padding(.top, 8)

            Spacer()

            VStack(spacing: 8) {
                Text("ONE MORE")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .tracking(7)
                    .foregroundStyle(.white.opacity(0.72))
                Text("TAP")
                    .font(.system(size: 76, weight: .black, design: .rounded))
                    .tracking(-3)
                    .foregroundStyle(
                        LinearGradient(colors: [.white, .cyan], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .cyan.opacity(0.45), radius: 24)
            }

            Spacer().frame(height: 52)

            Button {
                recordedGameOver = false
                game.start()
                if !stats.hasSeenOnboarding {
                    showHowTo = true
                    stats.hasSeenOnboarding = true
                    game.pause()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                    Text("CLASSIC")
                }
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 62)
                .background(
                    LinearGradient(colors: [.white, .cyan.opacity(0.9)], startPoint: .leading, endPoint: .trailing),
                    in: Capsule()
                )
                .shadow(color: .cyan.opacity(0.28), radius: 24, y: 8)
            }
            .padding(.horizontal, 38)

            Button { showHowTo = true } label: {
                Label("How to play", systemImage: "questionmark.circle")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
                    .padding(.vertical, 18)
            }

            Spacer()

            HStack(spacing: 0) {
                statCell(value: "\(stats.bestScore)", label: "BEST")
                Divider().overlay(.white.opacity(0.12)).frame(height: 38)
                statCell(value: "\(stats.runs)", label: "RUNS")
                Divider().overlay(.white.opacity(0.12)).frame(height: 38)
                statCell(value: "\(stats.perfects)", label: "PERFECT")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
    }

    private var gameplay: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Button { game.goHome() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityLabel("Exit run")

                Spacer()

                VStack(spacing: 2) {
                    Text("SCORE")
                        .font(.caption2.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.45))
                    Text("\(game.score)")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .contentTransition(.numericText())
                }

                Spacer()

                Text("#\(game.level)")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.cyan)
                    .frame(width: 58, height: 38)
                    .background(.cyan.opacity(0.11), in: Capsule())
                    .overlay(Capsule().stroke(.cyan.opacity(0.2), lineWidth: 1))
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            Spacer()

            ZStack {
                RadialTickRing()

                Circle()
                    .stroke(.white.opacity(0.07), lineWidth: 20)
                    .frame(width: 274, height: 274)

                Circle()
                    .stroke(.white.opacity(0.1), style: StrokeStyle(lineWidth: 2, dash: [2, 6]))
                    .frame(width: 274, height: 274)

                ArcShape(centerAngle: game.targetCenter, width: game.targetWidth)
                    .stroke(.cyan.opacity(0.20), style: StrokeStyle(lineWidth: 28, lineCap: .round))
                    .frame(width: 274, height: 274)
                    .blur(radius: 12)

                ArcShape(centerAngle: game.targetCenter, width: game.targetWidth)
                    .stroke(
                        LinearGradient(colors: [.cyan, .white, .cyan], startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 274, height: 274)
                    .animation(.spring(response: 0.28, dampingFraction: 0.72), value: game.targetCenter)

                ArcShape(centerAngle: game.targetCenter, width: game.targetWidth * ClassicRules.perfectFraction)
                    .stroke(.white.opacity(0.9), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 254, height: 254)

                TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
                    let angle = game.pointerAngle(at: timeline.date)
                    ZStack {
                        Capsule()
                            .fill(LinearGradient(colors: [.white.opacity(0.12), .white], startPoint: .bottom, endPoint: .top))
                            .frame(width: 4, height: 112)
                            .offset(y: -56)
                        Circle()
                            .fill(.white)
                            .frame(width: 18, height: 18)
                            .offset(y: -135)
                            .shadow(color: .white.opacity(0.85), radius: 8)
                            .shadow(color: .cyan.opacity(0.55), radius: 18)
                    }
                    .rotationEffect(.degrees(angle))
                }
                .frame(width: 274, height: 274)

                Circle()
                    .fill(.black.opacity(0.72))
                    .frame(width: 92, height: 92)
                    .overlay(Circle().stroke(.white.opacity(0.1), lineWidth: 1))
                    .shadow(color: .black.opacity(0.8), radius: 24)

                VStack(spacing: -2) {
                    Text("\(game.combo)")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                    Text("COMBO")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(.white.opacity(0.45))
                }
                .opacity(game.combo > 0 ? 1 : 0.3)

                Text(feedbackText)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(feedbackText == "PERFECT" ? .cyan : .white)
                    .shadow(color: .cyan.opacity(0.5), radius: 14)
                    .scaleEffect(feedbackScale)
                    .opacity(feedbackText.isEmpty ? 0 : 1)
                    .offset(y: -200)
            }
            .frame(width: 330, height: 360)
            .contentShape(Rectangle())
            .onTapGesture { _ = game.tap() }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Game area. Tap when the pointer reaches the glowing target.")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { _ = game.tap() }

            Spacer()

            Text("TAP THE GLOW")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(3.2)
                .foregroundStyle(.white.opacity(0.33))
                .padding(.bottom, 30)
        }
    }

    private var gameOver: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(isNewBest ? "NEW BEST" : "GAME OVER")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .tracking(4)
                .foregroundStyle(isNewBest ? .cyan : .white.opacity(0.5))

            Text("\(game.score)")
                .font(.system(size: 86, weight: .black, design: .rounded))
                .minimumScaleFactor(0.6)
                .foregroundStyle(.white)
                .shadow(color: isNewBest ? .cyan.opacity(0.35) : .clear, radius: 24)
                .padding(.top, 6)

            Text("LEVEL \(game.level)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(2.5)
                .foregroundStyle(.white.opacity(0.4))

            Spacer().frame(height: 54)

            Button {
                recordedGameOver = false
                isNewBest = false
                game.start()
            } label: {
                Label("ONE MORE TAP", systemImage: "arrow.clockwise")
                    .font(.system(size: 19, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                    .background(.white, in: Capsule())
            }
            .padding(.horizontal, 38)

            Button { game.goHome() } label: {
                Text("HOME")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(height: 54)
            }

            Spacer()
        }
        .onAppear { recordGameOverIfNeeded() }
    }

    private var howToOverlay: some View {
        ZStack {
            Color.black.opacity(0.78).ignoresSafeArea()
                .onTapGesture { dismissHowTo() }

            VStack(spacing: 26) {
                ZStack {
                    Circle().stroke(.white.opacity(0.1), lineWidth: 16).frame(width: 150, height: 150)
                    ArcShape(centerAngle: 60, width: 62)
                        .stroke(.cyan, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 150, height: 150)
                    Capsule().fill(.white).frame(width: 4, height: 58).offset(y: -29).rotationEffect(.degrees(48))
                    Circle().fill(.white).frame(width: 15, height: 15).offset(y: -74).rotationEffect(.degrees(48))
                }

                VStack(spacing: 9) {
                    Text("ONE RULE")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .tracking(4)
                        .foregroundStyle(.cyan)
                    Text("Tap inside the glow.")
                        .font(.system(size: 25, weight: .black, design: .rounded))
                    Text("Hit the bright center for PERFECT.\nMiss once and the run is over.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.62))
                        .lineSpacing(4)
                }

                Button { dismissHowTo() } label: {
                    Text("GOT IT")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(width: 180, height: 52)
                        .background(.white, in: Capsule())
                }
            }
            .padding(34)
        }
    }

    private var settingsSheet: some View {
        NavigationStack {
            Form {
                Section("Feedback") {
                    Toggle("Haptics", isOn: $stats.hapticsEnabled)
                }
                Section("Classic stats") {
                    LabeledContent("Best score", value: "\(stats.bestScore)")
                    LabeledContent("Best level", value: "\(stats.bestLevel)")
                    LabeledContent("Runs", value: "\(stats.runs)")
                    LabeledContent("Perfect hits", value: "\(stats.perfects)")
                    LabeledContent("Total score", value: "\(stats.totalScore)")
                }
                Section {
                    Button("Show tutorial") {
                        showSettings = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { showHowTo = true }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .preferredColorScheme(.dark)
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(.white.opacity(0.36))
        }
        .frame(maxWidth: .infinity)
    }

    private func dismissHowTo() {
        withAnimation(.easeOut(duration: 0.2)) { showHowTo = false }
        if game.phase == .playing { game.resume() }
    }

    private func handleFeedback() {
        guard let grade = game.lastGrade else { return }
        if stats.hapticsEnabled { Haptics.play(grade) }
        if grade == .perfect { stats.recordPerfect() }

        feedbackText = grade == .perfect ? "PERFECT" : (grade == .hit ? "HIT" : "MISS")
        feedbackScale = 0.65
        withAnimation(.spring(response: 0.22, dampingFraction: 0.55)) { feedbackScale = 1.08 }
        withAnimation(.easeOut(duration: 0.16)) { flashOpacity = grade == .miss ? 0.09 : 0.035 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            withAnimation(.easeOut(duration: 0.25)) { flashOpacity = 0 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.48) {
            withAnimation(.easeOut(duration: 0.18)) { feedbackText = "" }
        }
    }

    private func recordGameOverIfNeeded() {
        guard !recordedGameOver else { return }
        recordedGameOver = true
        isNewBest = stats.recordGame(score: game.score, level: game.level)
    }
}
