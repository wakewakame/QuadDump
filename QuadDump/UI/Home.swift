import SwiftUI

struct Home: View {
    let imu = IMURecorder()
    @State private var text = "IMU"

    var body: some View {
        Text(text)
        .onAppear {
            imu.preview { motion in
                self.text = String(motion.timestamp)
            }
        }
    }
}
