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
                "geotabId": 0,
                "xacc": 0.0,
                "yacc": 0.0,
                "zacc": 0.0,
                "x": x,
                "y": y
            ]
        
        print("latitude \(x)")
        print("longitude \(y)")

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300) 
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let jsonResponse = value as? [String: Any] {
                        if let data = jsonResponse["data"] as? [String: Any] {
                            if let id = data["id"] as? Int {
                                print("register id \(id)")
                                
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
}
