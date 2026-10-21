import SwiftUI

struct SkillLabView: View {
    @EnvironmentObject private var profile: PlayerProfile
    @Environment(\.locale) private var locale
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var store = SkillLabStore()
    @State private var engine: SkillLabEngine?
    @State private var result: SkillLabSummary?
    @State private var saved = false
    @State private var sessionID = UUID()
    let onExit: () -> Void
    private var de: Bool { locale.language.languageCode?.identifier == "de" }
    private func l(_ en: String, _ german: String) -> String { de ? german : en }
    private func title(_ drill: SkillDrill) -> String {
        switch drill { case .timing: l("Steady timing", "Gleichmäßiges Timing"); case .precision: l("Precision", "Präzision"); case .directions: l("Direction changes", "Richtungswechsel") }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Button { engine = nil; result = nil; onExit() } label: { Label(l("Home", "Startseite"), systemImage: "chevron.left") }
                    .buttonStyle(.bordered).controlSize(.large)
                Text("SKILL LAB").font(.largeTitle.bold())
                Text(l("Practice only. Classic records, coins and ad continues stay separate. Only completed practice results are saved on this device.", "Nur zum Üben. Classic-Rekorde, Münzen und Werbe-Continues bleiben getrennt. Nur abgeschlossene Übungsergebnisse werden auf diesem Gerät gespeichert."))
                    .font(.footnote).foregroundStyle(.secondary)
                if store.loadFailed {
                    Text(l("Practice data could not be loaded. Its file is preserved; saving is blocked.", "Übungsdaten konnten nicht geladen werden. Die Datei bleibt erhalten; Speichern ist gesperrt.")).foregroundStyle(.red)
                    Button(l("Retry loading", "Erneut laden")) { store.reload() }.buttonStyle(.bordered)
                }
                if store.saveFailed { Text(l("Saving failed. Your result remains here; retry saving below.", "Speichern fehlgeschlagen. Dein Ergebnis bleibt hier; versuche es unten erneut.")).foregroundStyle(.red) }
                if let result {
                    resultView(result)
                } else if let engine {
                    activeView(engine)
                } else {
                    ForEach(SkillDrill.allCases, id: \.rawValue) { drill in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(title(drill)).font(.title2.bold())
                            Text(description(drill)).foregroundStyle(.secondary)
                            if let best = store.progress.best(for: drill) { Text(l("Personal best: ", "Eigener Bestwert: ") + metrics(best)).font(.subheadline) }
                            Button(l("Start 12 attempts", "12 Versuche starten")) { start(drill) }
                                .buttonStyle(.borderedProminent).controlSize(.large).disabled(store.loadFailed)
                        }.padding().frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 20))
                    }
                    if !store.progress.recent.isEmpty {
                        Text(l("Recent practice", "Letzte Übungen")).font(.title2.bold())
                        ForEach(store.progress.recent) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(title(item.drill)).font(.headline)
                                Text(item.finishedAt, format: .dateTime.month().day().hour().minute())
                                Text(metrics(item))
                            }.font(.subheadline)
                        }
                    }
                }
            }.padding(22).frame(maxWidth: 620, alignment: .leading).frame(maxWidth: .infinity)
        }
        .tint(profile.selectedTheme.primary)
        .task(id: sessionID) {
            var previous = ContinuousClock.now
            while !Task.isCancelled && engine != nil && result == nil {
                do { try await Task.sleep(for: .milliseconds(16)) } catch { break }
                let now = ContinuousClock.now
                let duration = previous.duration(to: now).components
                previous = now
                if engine?.isPaused == false && engine?.lastFeedback == nil {
                    engine?.tick(seconds: Double(duration.seconds) + Double(duration.attoseconds) / 1e18)
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in if phase != .active { engine?.pause() } }
        .onDisappear { engine?.pause() }
    }
    private func description(_ drill: SkillDrill) -> String {
        switch drill {
        case .timing: l("A wide target at a steady speed. Learn the center timing without ending on a miss.", "Ein breites Ziel bei gleichmäßiger Geschwindigkeit. Übe die Mitte, ohne bei einem Fehltap auszuscheiden.")
        case .precision: l("A smaller, faster target calibrated to Classic difficulty 40.", "Ein kleineres, schnelleres Ziel mit der Classic-Schwierigkeit 40.")
        case .directions: l("Movement alternates after every attempt. Early and late follow the current direction.", "Die Bewegung wechselt nach jedem Versuch die Richtung. Früh und spät beziehen sich auf die aktuelle Richtung.")
        }
    }
    private func activeView(_ current: SkillLabEngine) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title(current.drill)).font(.title2.bold())
            Text(l("Attempt", "Versuch") + " \(min(12, current.attempts.count + (current.lastFeedback == nil ? 1 : 0)))/12").font(.headline)
            Text(current.direction == 1 ? l("Counterclockwise ↺", "Gegen den Uhrzeigersinn ↺") : l("Clockwise ↻", "Im Uhrzeigersinn ↻"))
            Text(l("Target width", "Zielbreite") + " \(current.drill.difficulty.targetArcDegrees.formatted(.number.precision(.fractionLength(1))))°")
                .font(.footnote).foregroundStyle(.secondary)
            Button { tap() } label: { ring(current).aspectRatio(1, contentMode: .fit).frame(maxWidth: 360) }
                .buttonStyle(.plain).frame(maxWidth: .infinity)
                .accessibilityLabel(l("Tap the moving marker at the target", "Tippe, wenn die Markierung das Ziel erreicht"))
                .disabled(current.isPaused || current.lastFeedback != nil)
            if current.isPaused {
                Text(l("Paused. Resume when ready.", "Pausiert. Setze fort, wenn du bereit bist.")).font(.headline)
                Button(l("Resume", "Fortsetzen")) { engine?.resume() }.buttonStyle(.borderedProminent).controlSize(.large)
            } else if let feedback = current.lastFeedback {
                Text(feedbackText(feedback)).font(.title3.bold())
                Button(l("Next attempt", "Nächster Versuch")) { _ = engine?.nextTrial() }.buttonStyle(.borderedProminent).controlSize(.large)
            } else {
                Button(l("TAP", "TIPPEN")) { tap() }.buttonStyle(.borderedProminent).controlSize(.large).frame(maxWidth: .infinity)
                Button(l("Pause", "Pause")) { engine?.pause() }.buttonStyle(.bordered).controlSize(.large)
            }
            Button(l("Back to drills", "Zur Übungsauswahl")) { engine = nil }.buttonStyle(.bordered).controlSize(.large)
        }
    }
    private func ring(_ current: SkillLabEngine) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2), radius = min(size.width, size.height) * 0.39
            let bounds = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
            context.stroke(Path(ellipseIn: bounds), with: .color(.white.opacity(0.18)), lineWidth: 5)
            func point(_ angle: Double) -> CGPoint { CGPoint(x: center.x + radius * CGFloat(cos(angle * .pi / 180)), y: center.y - radius * CGFloat(sin(angle * .pi / 180))) }
            func arc(_ width: Double) -> Path {
                Path { path in for index in 0...60 { let p = point(current.targetAngle - width / 2 + width * Double(index) / 60); if index == 0 { path.move(to: p) } else { path.addLine(to: p) } } }
            }
            context.stroke(arc(current.drill.difficulty.targetArcDegrees), with: .color(profile.selectedTheme.primary.opacity(0.55)), style: StrokeStyle(lineWidth: 14, lineCap: .round))
            context.stroke(arc(current.drill.difficulty.perfectArcDegrees), with: .color(profile.selectedTheme.secondary), style: StrokeStyle(lineWidth: 16, lineCap: .round))
            let marker = point(current.markerAngle)
            context.fill(Path(ellipseIn: CGRect(x: marker.x - 9, y: marker.y - 9, width: 18, height: 18)), with: .color(.white))
            context.draw(Text(current.isPaused ? l("PAUSED", "PAUSE") : l("TAP", "TIPPEN")).font(.headline).foregroundColor(.white), at: center)
        }
    }
    private func resultView(_ summary: SkillLabSummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title(summary.drill) + l(" complete", " abgeschlossen")).font(.title2.bold())
            Text(metrics(summary)).font(.headline)
            if let best = store.progress.best(for: summary.drill) { Text(l("Personal best: ", "Eigener Bestwert: ") + metrics(best)) }
            Text(l("Best ranks by hits, then perfects, then lower mean error.", "Bestwerte zählen zuerst Treffer, dann perfekte Treffer und zuletzt den kleineren mittleren Fehler.")).font(.footnote).foregroundStyle(.secondary)
            Text(l("Late (+) / on time (0) / early (−)", "Spät (+) / genau (0) / früh (−)")).font(.headline)
            Canvas { context, size in
                let mid = size.height / 2
                var axis = Path(); axis.move(to: CGPoint(x: 0, y: mid)); axis.addLine(to: CGPoint(x: size.width, y: mid))
                context.stroke(axis, with: .color(.white.opacity(0.5)), lineWidth: 1)
                for (index, item) in summary.attempts.enumerated() {
                    let x = size.width * (CGFloat(index) + 0.5) / 12
                    let y = mid - CGFloat(item.signedError) / 180 * (mid - 8)
                    context.fill(Path(ellipseIn: CGRect(x: x - 4, y: y - 4, width: 8, height: 8)), with: .color(item.quality == .miss ? .red : profile.selectedTheme.primary))
                }
            }.frame(height: 140).accessibilityHidden(true)
            ForEach(Array(summary.attempts.enumerated()), id: \.offset) { index, feedback in Text("\(index + 1). " + feedbackText(feedback)).font(.subheadline) }
            Text(l("Offsets show the nearest target crossing, in degrees. The chart spans −180° to +180°.", "Abweichungen zeigen die nächste Zielpassage in Grad. Das Diagramm reicht von −180° bis +180°.")).font(.footnote).foregroundStyle(.secondary)
            if !saved {
                Button(l("Save result", "Ergebnis speichern")) { saved = store.save(summary) }.buttonStyle(.borderedProminent).controlSize(.large).disabled(store.loadFailed)
            } else { Label(l("Saved on this device", "Auf diesem Gerät gespeichert"), systemImage: "checkmark.circle") }
            if !saved {
                Button(l("Discard result and choose a drill", "Ergebnis verwerfen und Übung wählen"), role: .destructive) { engine = nil; result = nil }.buttonStyle(.bordered).controlSize(.large)
            }
            Button(l("Repeat drill", "Übung wiederholen")) { start(summary.drill) }.buttonStyle(.bordered).controlSize(.large).disabled(!saved)
            Button(l("Back to drills", "Zur Übungsauswahl")) { engine = nil; result = nil }.buttonStyle(.bordered).controlSize(.large).disabled(!saved)
        }
    }
    private func feedbackText(_ feedback: SkillFeedback) -> String {
        let quality = feedback.quality == .perfect ? l("Perfect", "Perfekt") : feedback.quality == .good ? l("Hit", "Treffer") : l("Miss", "Verfehlt")
        let side = feedback.side == .early ? l("early", "früh") : feedback.side == .late ? l("late", "spät") : l("on time", "genau")
        return quality + " · " + side + " · " + abs(feedback.signedError).formatted(.number.precision(.fractionLength(1))) + "°"
    }
    private func metrics(_ summary: SkillLabSummary) -> String {
        "\(summary.hits)/12 " + l("hits", "Treffer") + " · \(summary.perfects) " + l("perfect", "perfekt") + " · " + summary.meanError.formatted(.number.precision(.fractionLength(1))) + "° " + l("mean error", "mittlerer Fehler")
    }
    private func start(_ drill: SkillDrill) { result = nil; saved = false; engine = SkillLabEngine(drill: drill); sessionID = UUID() }
    private func tap() {
        guard let feedback = try? engine?.tap() else { return }
        switch feedback.quality { case .perfect: FeedbackManager.perfect(enabled: profile.hapticsEnabled); case .good: FeedbackManager.good(enabled: profile.hapticsEnabled); case .miss: FeedbackManager.miss(enabled: profile.hapticsEnabled) }
        if let current = engine, current.isComplete, let summary = try? current.summary(at: .now) { result = summary; saved = store.save(summary) }
    }
}
