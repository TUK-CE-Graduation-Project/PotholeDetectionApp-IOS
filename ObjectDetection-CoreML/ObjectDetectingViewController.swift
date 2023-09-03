//
//  ObjectDetectingViewController.swift
//  ObjectDetection-CoreML
//
//  Created by 정서연 on 2023/09/02.
//  Copyright © 2023 tucan9389. All rights reserved.
//

import UIKit
import Vision
import CoreMedia
import AVFoundation
import CoreLocation
//import Alamofire



class ObjectDetectingViewController: UIViewController, AVCapturePhotoCaptureDelegate, CLLocationManagerDelegate{

    // MARK: - UI Properties
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var boxesView: DrawingBoundingBoxView!
    @IBOutlet weak var labelsTableView: UITableView!

    @IBOutlet weak var inferenceLabel: UILabel!
    @IBOutlet weak var etimeLabel: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!

    var photoOutput: AVCapturePhotoOutput!

    private var locationManager:CLLocationManager?


    lazy var objectDectectionModel = { return try? ObjectDetector() }()

    // MARK: - Vision Properties
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    var isInferencing = false

    // MARK: - AV Property
    var videoCapture: VideoCapture!
    let semaphore = DispatchSemaphore(value: 1)
    var lastExecution = Date()

    // MARK: - TableView Data
    var predictions: [VNRecognizedObjectObservation] = []

    // MARK - Performance Measurement Property
    private let 👨‍🔧 = 📏()

    let maf1 = MovingAverageFilter()
    let maf2 = MovingAverageFilter()
    let maf3 = MovingAverageFilter()

    let additionalData: [String: Any] = [
        "data": [
            "geotabId": 0,
            "xacc": 0,
            "yacc": 0,
            "zacc": 0,
            "x": 0,
            "y": 0
        ],
        "image": "string"
    ]
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        getUserLocation()

//        let videoPreview = UIView() // Create a new UIView
//        videoPreview.frame = CGRect(x: 0, y: 0, width: 320, height: 240) // Set its frame as needed
//        self.videoPreview = videoPreview
        
        // setup the model
        setUpModel()

        // setup camera
        setUpCamera()

        // setup delegate for performance measurement
        👨‍🔧.delegate = self
    }

    func getUserLocation(){
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("Lat: \(location.coordinate.latitude) \nLng: \(location.coordinate.longitude)")
        }
    }

    func requestPOST() {
            // [URL 지정 및 파라미터 값 지정 실시]
        let urlComponents = URLComponents(string: "https://?/api/pothole/register")
        let dicData = [
            "potholeRegistrationRequest":[
                "geotabId": 0,
                "xacc": 0,
                "yacc": 0,
                "zacc": 0,
                "point": [
                    "x": 0,
                    "y":0
                ]
            ] as [String : Any],
            "video":"S"
        ] as Dictionary<String, Any>?
        let jsonData = try! JSONSerialization.data(withJSONObject: dicData!, options: [])


            // [http 통신 타입 및 헤더 지정 실시]
            var requestURL = URLRequest(url: (urlComponents?.url)!)
            requestURL.httpMethod = "POST" // POST
            requestURL.addValue("application/json", forHTTPHeaderField: "Content-Type") // POST
        requestURL.httpBody = jsonData


            // [http 요쳥을 위한 URLSessionDataTask 생성]
            print("")
            print("====================================")
            print("[requestPOST : http post 요청 실시]")
            print("url : ", requestURL)
            print("====================================")
            print("")
            let dataTask = URLSession.shared.dataTask(with: requestURL) { (data, response, error) in

                // [error가 존재하면 종료]
                guard error == nil else {
                    print("")
                    print("====================================")
                    print("[requestPOST : http post 요청 실패]")
                    print("fail : ", error?.localizedDescription ?? "")
                    print("====================================")
                    print("")
                    return
                }

                // [status 코드 체크 실시]
                let successsRange = 200..<300
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, successsRange.contains(statusCode)
                else {
                    print("")
                    print("====================================")
                    print("[requestPOST : http post 요청 에러]")
                    print("error : ", (response as? HTTPURLResponse)?.statusCode ?? 0)
                    print("msg : ", (response as? HTTPURLResponse)?.description ?? "")
                    print("====================================")
                    print("")
                    return
                }


                // [response 데이터 획득, json 형태로 변환]
                let resultCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                let resultLen = data! // 데이터 길이
                do {
                    guard let jsonConvert = try JSONSerialization.jsonObject(with: data!) as? [String: Any] else {
                        print("")
                        print("====================================")
                        print("[requestPOST_BODY_JSON : http post body json 요청 에러]")
                        print("error : ", "json 형식 데이터 convert 에러")
                        print("====================================")
                        print("")
                        return
                    }
                    guard let JsonResponse = try? JSONSerialization.data(withJSONObject: jsonConvert, options: .prettyPrinted) else {
                        print("")
                        print("====================================")
                        print("[requestPOST_BODY_JSON : http post body json 요청 에러]")
                        print("error : ", "json 형식 데이터 변환 에러")
                        print("====================================")
                        print("")
                        return
                    }
                    guard let resultString = String(data: JsonResponse, encoding: .utf8) else {
                        print("Error: Couldn't print JSON in String")
                        print("")
                        print("====================================")
                        print("[requestPOST_BODY_JSON : http post body json 요청 에러]")
                        print("error : ", "json 형식 데이터 >> String 변환 에러")
                        print("====================================")
                        print("")
                        return
                    }
                    print("")
                    print("====================================")
                    print("[requestPOST_BODY_JSON : http post body json 요청 성공]")
                    print("resultCode : ", resultCode)
                    print("resultLen : ", resultLen)
                    print("resultString : ", resultString)
                    print("====================================")
                    print("")
                } catch {
                    print("")
                    print("====================================")
                    print("[requestPOST_BODY_JSON : http post body json 요청 에러]")
                    print("error : ", "Trying to convert JSON data to string")
                    print("====================================")
                    print("")
                    return
                }
            }

            // network 통신 실행
            dataTask.resume()
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoCapture.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoCapture.stop()
    }

    // MARK: - Setup Core ML
    func setUpModel() {
        guard let objectDectectionModel = objectDectectionModel else { fatalError("fail to load the model") }


        if let visionModel = try? VNCoreMLModel(for: objectDectectionModel.model) {
            self.visionModel = visionModel
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request?.imageCropAndScaleOption = .scaleFill
        } else {
            fatalError("fail to create vision model")
        }
    }


    // MARK: - SetUp Video
    func setUpCamera() {
        photoOutput = AVCapturePhotoOutput()
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 30
        if videoCapture.captureSession.canAddOutput(photoOutput) {
            videoCapture.captureSession.addOutput(photoOutput)
        }
        videoCapture.setUp(sessionPreset: .vga640x480) { [weak self] success in
            guard let self = self else { return }

            if success {
                // add preview view on the layer
                if let previewLayer = self.videoCapture.previewLayer {
                    DispatchQueue.main.async {
                        self.videoPreview.layer.addSublayer(previewLayer)
                        print(self.videoPreview)
                        self.resizePreviewLayer()
                    }
                }

                // start video preview when setup is done
                self.videoCapture.start()
            }
        }
    }

    // Add the following properties to your class
    var isPhotoCaptureEnabled = true
    var lastPhotoCaptureTime: Date?

    // Update the capturePhoto() method
    func capturePhoto() {
        guard isPhotoCaptureEnabled else {
            return
        }

        guard let videoPreviewLayer = videoCapture.previewLayer,
              let connection = videoPreviewLayer.connection,
              connection.isEnabled else {
            return
        }

        let currentTime = Date()
        if let lastCaptureTime = lastPhotoCaptureTime, currentTime.timeIntervalSince(lastCaptureTime) < 2.0 {
            // Less than 3 seconds have passed since the last capture
            return
        }

        lastPhotoCaptureTime = currentTime

        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }


    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            // 캡처된 사진 처리 (예: 저장, 표시 등)
            // 캡처된 이미지는 'image' 변수를 통해 액세스할 수 있습니다.
            
            ServerManager.shared.sendDatatoServer(image: image)

            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)

        }
    }


    @objc private func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // 사진 저장 중에 오류가 발생했을 때 처리할 내용
            print("사진 저장 중 오류 발생: \(error.localizedDescription)")
        } else {
            // 사진이 성공적으로 저장되었을 때 처리할 내용
            print("사진이 성공적으로 갤러리에 저장되었습니다.")
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }

    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
}

// MARK: - VideoCaptureDelegate
extension ObjectDetectingViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        // the captured image from camera is contained on pixelBuffer
        if !self.isInferencing, let pixelBuffer = pixelBuffer {
            self.isInferencing = true

            // start of measure
            self.👨‍🔧.🎬👏()

            // predict!
            self.predictUsingVision(pixelBuffer: pixelBuffer)
        }
    }
}

extension ObjectDetectingViewController {
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        guard let request = request else { fatalError() }
        // vision framework configures the input size of image following our model's input configuration automatically
        self.semaphore.wait()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
    }

    // MARK: - Post-processing
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        self.👨‍🔧.🏷(with: "endInference")
        if let predictions = request.results as? [VNRecognizedObjectObservation] {
//            print(predictions.first?.labels.first?.identifier ?? "nil")
//            print(predictions.first?.labels.first?.confidence ?? -1)
            let threshold: Float = 0.65 // Set the confidence threshold here
            _ = predictions.filter { $0.confidence >= threshold }


            if predictions.contains(where: { $0.label == "pothole"})&&predictions.contains(where: { $0.confidence >= threshold }) {
                        // Capture a photo
                        capturePhoto()
                    }
            self.predictions = predictions
            DispatchQueue.main.async {
                self.boxesView.predictedObjects = predictions
                self.labelsTableView.reloadData()

                // end of measure
                self.👨‍🔧.🎬🤚()

                self.isInferencing = false
            }
        } else {
            // end of measure
            self.👨‍🔧.🎬🤚()

            self.isInferencing = false
        }
        self.semaphore.signal()
    }
}

//func drawVisionRequestResults(_ results: [Any]) {
//       CATransaction.begin()
//       CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
//       detectionOverlay.sublayers = nil // remove all the old recognized objects
//       for observation in results where observation is VNRecognizedObjectObservation {
//           guard let objectObservation = observation as? VNRecognizedObjectObservation else {
//               continue
//           }
//           // Select only the label with the highest confidence.
//           let topLabelObservation = objectObservation.labels[0]
//           let confidenceThreshold: Float = 0.5
//           if topLabelObservation.confidence > confidenceThreshold {
//                           let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
//
//                           let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
//
//                           let textLayer = self.createTextSubLayerInBounds(objectBounds,
//                                                                           identifier: topLabelObservation.identifier,
//                                                                           confidence: topLabelObservation.confidence)
//                           shapeLayer.addSublayer(textLayer)
//                           detectionOverlay.addSublayer(shapeLayer)
//           }
//       }
//       self.updateLayerGeometry()
//       CATransaction.commit()
//   }

extension ObjectDetectingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell") else {
            return UITableViewCell()
        }

        let rectString = predictions[indexPath.row].boundingBox.toString(digit: 2)
        let confidence = predictions[indexPath.row].labels.first?.confidence ?? -1
        let confidenceString = String(format: "%.3f", confidence/*Math.sigmoid(confidence)*/)

        cell.textLabel?.text = predictions[indexPath.row].label ?? "N/A"
        cell.detailTextLabel?.text = "\(rectString), \(confidenceString)"
        return cell
    }
}

// MARK: - 📏(Performance Measurement) Delegate
extension ObjectDetectingViewController: 📏Delegate {
    func updateMeasure(inferenceTime: Double, executionTime: Double, fps: Int) {
        //print(executionTime, fps)
        DispatchQueue.main.async {
            self.maf1.append(element: Int(inferenceTime*1000.0))
            self.maf2.append(element: Int(executionTime*1000.0))
            self.maf3.append(element: fps)

            self.inferenceLabel.text = "inference: \(self.maf1.averageValue) ms"
            self.etimeLabel.text = "execution: \(self.maf2.averageValue) ms"
            self.fpsLabel.text = "fps: \(self.maf3.averageValue)"
        }
    }
}

class MovingAverageFilter {
    private var arr: [Int] = []
    private let maxCount = 10

    public func append(element: Int) {
        arr.append(element)
        if arr.count > maxCount {
            arr.removeFirst()
        }
    }

    public var averageValue: Int {
        guard !arr.isEmpty else { return 0 }
        let sum = arr.reduce(0) { $0 + $1 }
        return Int(Double(sum) / Double(arr.count))
    }
}

