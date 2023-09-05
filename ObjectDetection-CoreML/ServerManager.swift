//
//  ServerManager.swift
//  ObjectDetection-CoreML
//
//  Created by 정서연 on 2023/08/29.
//  Copyright © 2023 tucan9389. All rights reserved.
//




import Foundation
import UIKit
import Alamofire


/// <#Description#>
class ServerManager {
    // define shared singleton instance
    static let shared = ServerManager()
    
    // URL object definition
    let url = URL(string: "http://18.207.198.224:8080/api/pothole/register")!



    private init() {
        // Private initialization method to enforce the singleton pattern
    }

    func registerPotholeData(x: Double, y: Double, image: UIImage) {
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        
        let parameters: [String: Any] =
            [
                "geotabId": 20,
                "xacc": 1.0,
                "yacc": 0.0,
                "zacc": 0.0,
                "x": 37.60643331778227,
                "y": 127.09282015041511
            ]

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300) // Ensure a successful response status code
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let jsonResponse = value as? [String: Any] {
                        if let data = jsonResponse["data"] as? [String: Any] {
                            if let id = data["id"] as? Int {
                                print("register id \(id)")
                                
                                // Call the uploadImage function with a valid id
                                self.uploadImage(image: image, id: id)
                            } else {
                                print("Error: 'id' is nil in the data received from the server.")
                            }
                            let code = jsonResponse["code"] as? String
                            let message = jsonResponse["message"] as? String

                            //print("Pothole Data Data received: \(data)")
                            print("Pothole Data Response Code: \(String(describing: code))")
                            print("Pothole Data Response Message: \(String(describing: message))")
                        }
                    }
                case .failure(let error):
                    // Handle the error here
                    print("Error: \(error)")
                }
            }

    }


    func uploadImage(image: UIImage, id: Int) {
        let url = "http://18.207.198.224:8080/api/pothole/img/\(id)"
        let boundary = "Boundary-\(UUID().uuidString)"

        AF.upload(multipartFormData: { (multipartFormData:MultipartFormData) in
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                multipartFormData.append(imageData, withName: "image", fileName: "\(String(describing: id)).jpeg", mimeType: "image/jpeg")
                print("multipartFormData \(multipartFormData.contentLength)")
            }
        }, to: url, usingThreshold: UInt64(), method: .put, headers: ["Content-Type": "multipart/form-data; boundary=\(boundary)"])
        .response { response in
            switch response.result {
            case .success(let optionalData):
                // Unwrap the optional Data
                guard let data = optionalData else {
                    print("No data received")
                    return
                }

                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let jsonResponse = jsonResponse {
                        
                        let code = jsonResponse["code"] as? String ?? ""
                        let message = jsonResponse["message"] as? String ?? ""
                        let responseData = jsonResponse["data"] as? [String: Any] ?? [:]
                        
                        // Print the raw JSON response as a string
                        if let jsonDataString = String(data: data, encoding: .utf8) {
                            print("Raw JSON Response: \(jsonDataString)")
                        }
                        
                        print("받은 데이터: \(responseData)")
                        print("응답 코드: \(code)")
                        print("응답 메시지: \(message)")
                    }
                } else {
                    print("JSON 응답 디코딩 오류.")
                }
            case .failure(let error):
                print("이미지 업로드 실패. 에러: \(error)")
            }
        }
    }
//    func uploadImage(image: UIImage, id: Int) {
//
//        print("id \(id)")
//
//        let url = URL(string: "http://18.207.198.224:8080/api/pothole/img/\(id)")!
//
//        // Boundary 설정
//        let boundary = "Boundary-\(UUID().uuidString)"
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//
//        // HTTP 헤더 설정
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        let body = NSMutableData()
//
//        print("Before HTTP Body Size: \(body.count) bytes")
//
//
//        // 이미지 데이터 추가
//        if let imageData = image.jpegData(compressionQuality: 0.8) {
//            body.append("--\(boundary)\r\n".data(using: .utf8)!)
//            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(String(describing: id)).jpeg\"\r\n".data(using: .utf8)!)
//            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
//            body.append(imageData)
//            body.append("\r\n".data(using: .utf8)!)
//        }
//
//        request.httpBody = body as Data
//
//        print("After HTTP Body Size: \(body.count) bytes")
//
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("이미지 업로드 실패. 에러: \(error)")
//                return
//            }
//
//            guard let data = data else {
//                print("데이터가 없습니다.")
//                return
//            }
//
//            do {
//                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                    print("jsonResponse 데이터: \(jsonResponse)")
//
//                    let code = jsonResponse["code"] as? String ?? ""
//                    let message = jsonResponse["message"] as? String ?? ""
//                    let responseData = jsonResponse["data"] as? [String: Any] ?? [:]
//
//                    // 응답 데이터, 코드, 메시지 등을 처리합니다.
//                    print("받은 데이터: \(responseData)")
//                    print("응답 코드: \(code)")
//                    print("응답 메시지: \(message)")
//                } else {
//                    print("JSON 응답 디코딩 오류.")
//                }
//            } catch {
//                print("JSON 응답 디코딩 오류: \(error)")
//            }
//        }
//
//        task.resume()
//    }

}
