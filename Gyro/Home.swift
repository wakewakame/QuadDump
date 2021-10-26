import SwiftUI
import simd

struct Home: View {
    var imu = IMURecorder()
    @State private var preview: [IMUPreview] = []

    var body: some View {
        VStack {
            if let prev = preview.last { RotatePreview(euler: prev.attitude) }
            ZStack {
                VStack {
                    Graph(values: preview.map { prev -> CGFloat in (0.1 * prev.rotationRate.0) }, color: 0xfe3b30, title: "gyro x")
                    Graph(values: preview.map { prev -> CGFloat in (0.1 * prev.rotationRate.1) }, color: 0xfe3b30, title: "gyro y")
                    Graph(values: preview.map { prev -> CGFloat in (0.1 * prev.rotationRate.2) }, color: 0xfe3b30, title: "gyro z")
                }
                VStack {
                    Graph(values: preview.map { prev -> CGFloat in (0.1 * prev.estimated3Axis.0) }, color: 0xffffff, title: "gyro x")
                    Graph(values: preview.map { prev -> CGFloat in (0.1 * prev.estimated3Axis.1) }, color: 0xffffff, title: "gyro y")
                    Graph(values: preview.map { prev -> CGFloat in (0.1 * prev.estimated3Axis.2) }, color: 0xffffff, title: "gyro z")
                }
            }
        }
        .onAppear {
            imu.preview { prev in
                var p2 = prev
                if let p1 = preview.last {
                    let euler1 = simd_double3(p1.attitude.0, p1.attitude.1, p1.attitude.2)
                    let euler2 = simd_double3(p2.attitude.0, p2.attitude.1, p2.attitude.2)
                    var euler_ = euler2 - euler1
                    let pi: Double = acos(-1.0)

                    // (-pi < euler_ < pi)に正規化
                    euler_ -= simd_double3(
                        2.0 * pi * floor((euler_.x + pi) / (2.0 * pi)),
                        2.0 * pi * floor((euler_.y + pi) / (2.0 * pi)),
                        2.0 * pi * floor((euler_.z + pi) / (2.0 * pi))
                    )

                    let imu2world = simd_double3x3(rows: [
                        simd_double3(1,  sin(euler2.x) * tan(euler2.y),  cos(euler2.x) * tan(euler2.y)),
                        simd_double3(0,  cos(euler2.x)                , -sin(euler2.x)                ),
                        simd_double3(0, -sin(euler2.x) / cos(euler2.y),  cos(euler2.x) / cos(euler2.y))
                    ])
                    let world2imu = imu2world.inverse
                    let estimatedImu = world2imu * euler_ / (p2.timestamp - p1.timestamp)
                    p2.estimated3Axis = (estimatedImu.y, estimatedImu.x, estimatedImu.z)
                }
                preview.append(p2)
                while preview.count > 1000 {
                    preview.removeFirst()
                }
            }
        }
    }
}
