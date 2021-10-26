import SwiftUI
import AudioToolbox

struct Graph: View {
    let values: [CGFloat]
    let color: UInt32
    let title: String

    var body: some View {
        ZStack(alignment: .center) {
            GraphShape(values: values).stroke(Color(hex: color), lineWidth: 2).border(Color(hex: color))
            VStack() { HStack() { Text(title); Spacer() }; Spacer() }
        }
    }
}

struct GraphShape: Shape {
    let values: [CGFloat]
    func path(in rect: CGRect) -> Path {

        let path = Path { path in
            if values.count <= 1 { return }
            for (i, value) in values.enumerated() {
                let x: CGFloat = CGFloat(rect.width) * CGFloat(i) / CGFloat(values.count - 1)
                let y: CGFloat = CGFloat(rect.midY) - 0.5 * CGFloat(rect.height) * min(max(CGFloat(value), -1.0), 1.0)
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                }
                else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }

        return path
    }
}
