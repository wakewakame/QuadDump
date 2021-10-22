import SwiftUI

struct Home: View {
    var imu = IMURecorder()
    @State private var preview: [IMUPreview] = []

    var body: some View {
        VStack {
            Graph(values: preview.map { prev -> CGFloat in prev.gravity.0 }, color: 0xfe3b30, title: "gravity x")
            Graph(values: preview.map { prev -> CGFloat in prev.gravity.1 }, color: 0xfe3b30, title: "gravity y")
            Graph(values: preview.map { prev -> CGFloat in prev.gravity.2 }, color: 0xfe3b30, title: "gravity z")
            Graph(values: preview.map { prev -> CGFloat in prev.rotationRate.0 }, color: 0xfe3b30, title: "gravity x")
            Graph(values: preview.map { prev -> CGFloat in prev.rotationRate.1 }, color: 0xfe3b30, title: "gravity y")
            Graph(values: preview.map { prev -> CGFloat in prev.rotationRate.2 }, color: 0xfe3b30, title: "gravity z")
            Graph(values: preview.map { prev -> CGFloat in prev.attitude.0 }, color: 0xfe3b30, title: "gravity x")
            Graph(values: preview.map { prev -> CGFloat in prev.attitude.1 }, color: 0xfe3b30, title: "gravity y")
            Graph(values: preview.map { prev -> CGFloat in prev.attitude.2 }, color: 0xfe3b30, title: "gravity z")
        }
        .onAppear {
            imu.preview { prev in
                preview.append(prev)
                while preview.count > 1000 {
                    preview.removeFirst()
                }
            }
        }
    }
}
