import CoreLocation

class GPSRecorder: NSObject, CLLocationManagerDelegate {
    // GPSにアクセスするためのクラス
    private let locationManager = CLLocationManager()

    // GPSへのアクセスが開始されているか
    private var isEnable: Bool = false

    // 録画が開始されているか
    private var isRecording: Bool = false

    // 録画開始時刻
    private var startTime: TimeInterval = ProcessInfo.processInfo.systemUptime

    // IMUから最後にデータを取得した時刻
    private var lastUpdate: TimeInterval = 0.0

    // 最後にpreviewCallbackを呼んだ時刻
    private var previewLastUpdate: TimeInterval = 0.0

    // IMUのプレビューを表示するときに呼ぶコールバック関数
    private var previewCallback: ((GPSPreview) -> ())? = nil

    // インスタンス作成時刻
    private let systemUptime = Date(timeIntervalSinceNow: -ProcessInfo.processInfo.systemUptime)

    deinit {
        if isEnable { let _ = disable() }
    }

    // プレビューデータを受け取るコールバック関数の登録
    func preview(_ preview: ((GPSPreview) -> ())?) {
        previewCallback = preview
    }

    // GPSへのアクセスを開始
    func enable() -> SimpleResult {
        if isEnable { return Err("GPSは既に開始しています") }

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        isEnable = true

        return Ok()
    }

    // GPSへのアクセスを停止
    func disable() -> SimpleResult {
        if (!isEnable) { return Err("GPSは既に終了しています") }

        if isRecording { let _ = stop() }  // 録画中であれば録画を終了
        locationManager.stopUpdatingLocation()
        isEnable = false

        return Ok()
    }

    // 録画開始
    func start(_ startTime: TimeInterval) -> SimpleResult {
        self.startTime = startTime
        isRecording = true
        return Ok()
    }

    // 録画終了
    func stop() -> SimpleResult {
        isRecording = false
        return Ok()
    }

    // GPSが更新されたときに呼ばれるメソッド
    func locationManager(_ locationManager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for (index, location) in locations.enumerated() {
            // システムが起動してからの時刻に変換
            let timestamp = systemUptime.distance(to: location.timestamp)

            let fps = 1.0 / (timestamp - lastUpdate)
            lastUpdate = timestamp
            
            let preview = GPSPreview(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                altitude: location.altitude,
                horizontalAccuracy: location.horizontalAccuracy,
                verticalAccuracy: location.verticalAccuracy,
                timestamp: timestamp - startTime,
                fps: fps
            )

            if index == (locations.count - 1) {
                if (timestamp - previewLastUpdate) > 0.1 {
                    previewLastUpdate = timestamp
                    previewCallback?(preview)
                }
            }
        }
    }

    // GPSへのアクセス権限が変更されたときに呼ばれるDelegate
    func locationManagerDidChangeAuthorization(_ locationManager: CLLocationManager) {
        switch locationManager.authorizationStatus {
        case .restricted, .denied, .notDetermined:     // GPSへのアクセス権がないとき
            break
        case .authorizedAlways, .authorizedWhenInUse:  // GPSへのアクセス権があるとき
            // 高精度のGPS座標取得を要求
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "trajectory")
        }
    }

    struct GPSPreview {
        let latitude: Double            // 緯度
        let longitude: Double           // 経度
        let altitude: Double            // 高度
        let horizontalAccuracy: Double  // メートル単位で表されるlatitude, longitudeの誤差の半径
        let verticalAccuracy: Double    // メートル単位で表されるaltitudeの誤差
        let timestamp: TimeInterval
        let fps: Double
    }
}