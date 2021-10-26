import SwiftUI
import AudioToolbox
import simd

struct RotatePreview: View {
    let euler: simd_double3
    @State private var resetRotate: simd_double4x4 = simd_double4x4(rows: [
        simd_double4(1, 0, 0, 0),
        simd_double4(0, 1, 0, 0),
        simd_double4(0, 0, 1, 0),
        simd_double4(0, 0, 0, 1)
    ])

    init(euler: (Double, Double, Double)) {
        self.euler = simd_double3(euler.0, euler.1, euler.2)
    }

    var body: some View {
        ZStack(alignment: .center) {
            Color(hex: 0x000000)
            RotatePreviewShape(euler: euler, resetRotate: resetRotate)
                .stroke(Color(hex: 0xfe3b30), lineWidth: 4)
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onEnded { _ in resetRotate = getRotateMatrix(euler).inverse }
        )
    }
}

struct RotatePreviewShape: Shape {
    let euler: simd_double3
    let resetRotate: simd_double4x4

    func path(in rect: CGRect) -> Path {

        let verticies: [simd_double4] = [
            simd_double4(-0.9, -1.6, 0.0, 1.0),
            simd_double4(+0.9, -1.6, 0.0, 1.0),
            simd_double4(+0.9, +1.6, 0.0, 1.0),
            simd_double4(-0.9, +1.6, 0.0, 1.0),
        ]

        let f: Double = 400.0;

        let proj = simd_double4x4(rows: [
            simd_double4(f,  0, 0, 0),
            simd_double4(0, -f, 0, 0),
            simd_double4(0,  0, 1, 0),
            simd_double4(0,  0, 1, 0)
        ])

        let trans = simd_double4x4(rows: [
            simd_double4(1, 0, 0, 0),
            simd_double4(0, 1, 0, 0),
            simd_double4(0, 0, 1, f / 80.0),
            simd_double4(0, 0, 0, 1)
        ])

        let rotate = getRotateMatrix(euler)

        let path = Path { path in
            if verticies.count <= 1 { return }
            for (i, vertex) in verticies.enumerated() {
                let vertex_ = proj * trans * resetRotate * rotate * vertex
                let x: CGFloat = (vertex_.x / vertex_.w) + Double(rect.midX)
                let y: CGFloat = (vertex_.y / vertex_.w) + Double(rect.midY)
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                }
                else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.closeSubpath()
        }

        return path
    }
}

func getRotateMatrix(_ euler: simd_double3) -> simd_double4x4 {
    let roll = simd_double4x4(rows: [
        simd_double4(+cos(euler.x), 0, -sin(euler.x), 0),
        simd_double4(0            , 1, 0            , 0),
        simd_double4(+sin(euler.x), 0, +cos(euler.x), 0),
        simd_double4(0            , 0, 0            , 1)
    ])

    let pitch = simd_double4x4(rows: [
        simd_double4(1, 0             , 0             , 0),
        simd_double4(0, +cos(-euler.y), -sin(-euler.y), 0),
        simd_double4(0, +sin(-euler.y), +cos(-euler.y), 0),
        simd_double4(0, 0             , 0             , 1)
    ])

    let yaw = simd_double4x4(rows: [
        simd_double4(+cos(euler.z), -sin(euler.z), 0, 0),
        simd_double4(+sin(euler.z), +cos(euler.z), 0, 0),
        simd_double4(0            , 0            , 1, 0),
        simd_double4(0            , 0            , 0, 1)
    ])

    return yaw * pitch * roll
}
