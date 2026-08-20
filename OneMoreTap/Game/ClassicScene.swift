import SpriteKit
import UIKit

@MainActor
final class ClassicScene: SKScene {
  var onScore: ((Int, Int, Int, HitQuality) -> Void)?
  var onGameOver: ((Int, Int) -> Void)?
  var soundEnabled = true
  var hapticsEnabled = true

  private var engine = ClassicGameEngine()
  private let ringNode = SKShapeNode()
  private let targetNode = SKShapeNode()
  private let perfectNode = SKShapeNode()
  private let markerNode = SKShapeNode(circleOfRadius: 11)
  private let centerGlowNode = SKShapeNode(circleOfRadius: 54)
  private let instructionNode = SKLabelNode(fontNamed: "AvenirNext-DemiBold")

  private var currentAngle = 0.0
  private var targetAngle = 0.0
  private var direction = 1.0
  private var lastUpdateTime = 0.0
  private var orbitRadius = 135.0
  private var hasStartedMoving = false
  private var runIsPaused = false

  override init(size: CGSize) {
    super.init(size: size)
    scaleMode = .resizeFill
    backgroundColor = .clear
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    isUserInteractionEnabled = true
    setupNodes()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMove(to view: SKView) {
    view.allowsTransparency = true
    view.backgroundColor = .clear
    view.ignoresSiblingOrder = true
    layoutArena()
  }

  override func didChangeSize(_ oldSize: CGSize) {
    super.didChangeSize(oldSize)
    layoutArena()
  }

  func startNewRun() {
    removeAllActions()
    for child in children where child.name == "burst" || child.name == "floatingText" {
      child.removeFromParent()
    }
    engine.reset()
    currentAngle = Double.random(in: 0..<360)
    targetAngle = Self.randomTargetAngle(avoiding: currentAngle)
    direction = Bool.random() ? 1 : -1
    lastUpdateTime = 0
    hasStartedMoving = false
    runIsPaused = false
    isPaused = false
    instructionNode.alpha = 1
    instructionNode.text = "TAP THE TARGET"
    markerNode.alpha = 1
    updateTargetPath()
    updateMarkerPosition()
    pulseStart()
  }

  func setPaused(_ paused: Bool) {
    runIsPaused = paused
    isPaused = paused
    if !paused {
      lastUpdateTime = 0
    }
  }

  override func update(_ currentTime: TimeInterval) {
    guard !engine.isGameOver, !runIsPaused else { return }
    if lastUpdateTime == 0 {
      lastUpdateTime = currentTime
      return
    }

    let delta = min(1.0 / 20.0, currentTime - lastUpdateTime)
    lastUpdateTime = currentTime
    let difficulty = engine.difficulty()
    let radiansPerSecond = difficulty.angularSpeed
    currentAngle = ClassicGameEngine.normalizeDegrees(
      currentAngle + direction * radiansPerSecond * delta * 180.0 / .pi)
    updateMarkerPosition()
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard !engine.isGameOver, !runIsPaused else { return }
    if !hasStartedMoving {
      hasStartedMoving = true
      instructionNode.run(.fadeOut(withDuration: 0.22))
    }
    evaluateTap()
  }

  private func setupNodes() {
    ringNode.strokeColor = UIColor.white.withAlphaComponent(0.12)
    ringNode.lineWidth = 2
    ringNode.glowWidth = 2
    addChild(ringNode)

    targetNode.strokeColor = UIColor(red: 0.23, green: 0.92, blue: 1.0, alpha: 0.95)
    targetNode.lineWidth = 14
    targetNode.lineCap = .round
    targetNode.glowWidth = 8
    addChild(targetNode)

    perfectNode.strokeColor = UIColor.white.withAlphaComponent(0.95)
    perfectNode.lineWidth = 4
    perfectNode.lineCap = .round
    perfectNode.glowWidth = 6
    addChild(perfectNode)

    markerNode.fillColor = .white
    markerNode.strokeColor = UIColor(red: 0.33, green: 0.95, blue: 1.0, alpha: 1)
    markerNode.lineWidth = 3
    markerNode.glowWidth = 7
    markerNode.zPosition = 20
    addChild(markerNode)

    centerGlowNode.fillColor = UIColor.white.withAlphaComponent(0.025)
    centerGlowNode.strokeColor = UIColor.white.withAlphaComponent(0.055)
    centerGlowNode.lineWidth = 1
    centerGlowNode.zPosition = -2
    addChild(centerGlowNode)

    instructionNode.text = "TAP THE TARGET"
    instructionNode.fontSize = 13
    instructionNode.fontColor = UIColor.white.withAlphaComponent(0.42)
    instructionNode.verticalAlignmentMode = .center
    instructionNode.horizontalAlignmentMode = .center
    instructionNode.zPosition = 10
    addChild(instructionNode)

    addAmbientDots()
  }

  private func layoutArena() {
    orbitRadius = min(size.width * 0.34, size.height * 0.245)
    ringNode.path = CGPath(
      ellipseIn: CGRect(
        x: -orbitRadius, y: -orbitRadius, width: orbitRadius * 2, height: orbitRadius * 2),
      transform: nil)
    instructionNode.position = CGPoint(x: 0, y: -4)
    updateTargetPath()
    updateMarkerPosition()
  }

  private func addAmbientDots() {
    for index in 0..<26 {
      let dot = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.6...1.8))
      dot.name = "ambient"
      dot.fillColor = UIColor.white.withAlphaComponent(CGFloat.random(in: 0.05...0.18))
      dot.strokeColor = .clear
      let theta = CGFloat(index) / 26.0 * .pi * 2 + CGFloat.random(in: -0.12...0.12)
      let radius = CGFloat.random(in: 185...330)
      dot.position = CGPoint(x: cos(theta) * radius, y: sin(theta) * radius)
      dot.zPosition = -5
      addChild(dot)
    }
  }

  private func evaluateTap() {
    let result = engine.evaluateTap(markerAngle: currentAngle, targetAngle: targetAngle)
    switch result.quality {
    case .perfect:
      FeedbackManager.perfect(enabled: hapticsEnabled)
      playSound(named: "perfect.wav")
      showBurst(perfect: true)
      showFloatingText("PERFECT +\(result.scoreDelta)")
      advanceAfterHit(result)
    case .good:
      FeedbackManager.good(enabled: hapticsEnabled)
      playSound(named: "hit.wav")
      showBurst(perfect: false)
      advanceAfterHit(result)
    case .miss:
      FeedbackManager.miss(enabled: hapticsEnabled)
      playSound(named: "fail.wav")
      failAnimation()
      onScore?(engine.score, engine.combo, engine.coinsEarned, .miss)
      onGameOver?(engine.score, engine.coinsEarned)
    }
  }

  private func advanceAfterHit(_ result: HitResult) {
    onScore?(engine.score, engine.combo, engine.coinsEarned, result.quality)
    let difficulty = engine.difficulty()
    if difficulty.reversesDirection && Double.random(in: 0...1) < 0.30 {
      direction *= -1
    }
    targetAngle = Self.randomTargetAngle(avoiding: currentAngle)
    updateTargetPath()
    pulseRing()
  }

  private func updateTargetPath() {
    let difficulty = engine.difficulty()
    targetNode.path = arcPath(
      centerAngle: targetAngle, arcDegrees: difficulty.targetArcDegrees, radius: orbitRadius)
    perfectNode.path = arcPath(
      centerAngle: targetAngle, arcDegrees: difficulty.perfectArcDegrees, radius: orbitRadius)
  }

  private func arcPath(centerAngle: Double, arcDegrees: Double, radius: CGFloat) -> CGPath {
    let start = CGFloat((centerAngle - arcDegrees / 2) * .pi / 180)
    let end = CGFloat((centerAngle + arcDegrees / 2) * .pi / 180)
    let path = CGMutablePath()
    path.addArc(center: .zero, radius: radius, startAngle: start, endAngle: end, clockwise: false)
    return path
  }

  private func updateMarkerPosition() {
    let radians = CGFloat(currentAngle * .pi / 180)
    markerNode.position = CGPoint(x: cos(radians) * orbitRadius, y: sin(radians) * orbitRadius)
  }

  private func pulseStart() {
    let action = SKAction.sequence([
      .scale(to: 1.08, duration: 0.22),
      .scale(to: 1.0, duration: 0.28),
    ])
    markerNode.run(action)
  }

  private func pulseRing() {
    ringNode.removeAction(forKey: "pulse")
    let brighten = SKAction.customAction(withDuration: 0.12) { node, elapsed in
      guard let shape = node as? SKShapeNode else { return }
      let progress = elapsed / 0.12
      shape.strokeColor = UIColor.white.withAlphaComponent(0.12 + 0.18 * progress)
    }
    let dim = SKAction.customAction(withDuration: 0.22) { node, elapsed in
      guard let shape = node as? SKShapeNode else { return }
      let progress = elapsed / 0.22
      shape.strokeColor = UIColor.white.withAlphaComponent(0.30 - 0.18 * progress)
    }
    ringNode.run(.sequence([brighten, dim]), withKey: "pulse")
  }

  private func showBurst(perfect: Bool) {
    let count = perfect ? 18 : 9
    let origin = markerNode.position
    for index in 0..<count {
      let particle = SKShapeNode(circleOfRadius: perfect ? 2.6 : 2.0)
      particle.name = "burst"
      particle.fillColor =
        index.isMultiple(of: 2) ? .white : UIColor(red: 0.26, green: 0.92, blue: 1, alpha: 1)
      particle.strokeColor = .clear
      particle.position = origin
      particle.zPosition = 30
      addChild(particle)

      let angle = CGFloat(index) / CGFloat(count) * .pi * 2 + CGFloat.random(in: -0.18...0.18)
      let distance = CGFloat.random(in: perfect ? 34...58 : 22...38)
      let destination = CGPoint(
        x: origin.x + cos(angle) * distance, y: origin.y + sin(angle) * distance)
      particle.run(
        .sequence([
          .group([
            .move(to: destination, duration: perfect ? 0.34 : 0.24),
            .fadeOut(withDuration: perfect ? 0.34 : 0.24),
            .scale(to: 0.2, duration: perfect ? 0.34 : 0.24),
          ]),
          .removeFromParent(),
        ]))
    }
  }

  private func showFloatingText(_ text: String) {
    let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
    label.name = "floatingText"
    label.text = text
    label.fontSize = 15
    label.fontColor = .white
    label.position = CGPoint(x: markerNode.position.x, y: markerNode.position.y + 30)
    label.zPosition = 40
    addChild(label)
    label.run(
      .sequence([
        .group([.moveBy(x: 0, y: 32, duration: 0.48), .fadeOut(withDuration: 0.48)]),
        .removeFromParent(),
      ]))
  }

  private func failAnimation() {
    markerNode.run(
      .sequence([
        .scale(to: 1.7, duration: 0.09),
        .fadeOut(withDuration: 0.20),
      ]))
    targetNode.run(
      .sequence([
        .fadeAlpha(to: 0.25, duration: 0.12),
        .fadeAlpha(to: 1, duration: 0.18),
      ]))
  }

  private func playSound(named name: String) {
    guard soundEnabled else { return }
    run(.playSoundFileNamed(name, waitForCompletion: false))
  }

  private static func randomTargetAngle(avoiding angle: Double) -> Double {
    for _ in 0..<12 {
      let candidate = Double.random(in: 0..<360)
      let distance = ClassicGameEngine.shortestAngularDistanceDegrees(candidate, angle)
      if distance > 52 { return candidate }
    }
    return ClassicGameEngine.normalizeDegrees(angle + 120)
  }
}
