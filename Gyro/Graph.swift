import SwiftUI
import AudioToolbox

struct Graph: View {
    let values: [CGFloat]
    let color: UInt32
    let title: String

    var body: some View {
        ZStack {
            GraphShape(values: values).stroke(Color(hex: 0xfe3b30), lineWidth: 4)
            Text(title)
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
                let y: CGFloat = CGFloat(rect.midY) - 0.5 * CGFloat(rect.height) * CGFloat(value)
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                }
                else {
                    path.addLine( to: CGPoint(x: x, y: y))
                }
            }
        }

        return path
    }
}
