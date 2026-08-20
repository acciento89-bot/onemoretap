import SwiftUI

struct ArcShape: Shape {
    var centerAngle: Double
    var width: Double

    var animatableData: AnimatablePair<Double, Double> {
        get { .init(centerAngle, width) }
        set {
            centerAngle = newValue.first
            width = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(centerAngle - width / 2 - 90),
            endAngle: .degrees(centerAngle + width / 2 - 90),
            clockwise: false
        )
        return path
    }
}

struct RadialTickRing: View {
    var body: some View {
        ZStack {
            ForEach(0..<36, id: \.self) { index in
                Capsule()
                    .fill(.white.opacity(index.isMultiple(of: 3) ? 0.22 : 0.09))
                    .frame(width: index.isMultiple(of: 3) ? 2 : 1, height: index.isMultiple(of: 3) ? 9 : 5)
                    .offset(y: -149)
                    .rotationEffect(.degrees(Double(index) * 10))
            }
        }
        .frame(width: 310, height: 310)
        .accessibilityHidden(true)
    }
}
