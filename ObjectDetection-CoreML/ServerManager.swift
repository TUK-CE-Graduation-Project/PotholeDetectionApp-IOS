//
//  ServerManager.swift
//  ObjectDetection-CoreML
//
//  Created by 정서연 on 2023/08/29.
//  Copyright © 2023 tucan9389. All rights reserved.
//

import Foundation
//import Alamofire
import UIKit

class ServerManager {
    // 공유 싱글톤 인스턴스 정의
    static let shared = ServerManager()
    
    // URL 객체 정의
    let url = URL(string: "http://18.207.198.224:8080/api/pothole/register")!


    private init() {
        // 싱글톤 패턴을 강제하기 위한 프라이빗 초기화 메서드
    }

    // 이미지를 multipart/form-data로 POST 요청하는 함수
    func sendDatatoServer(image: UIImage) {
        
        // 이미지를 업로드할 때 사용할 파라미터
        let parameters = [
            "data": [
                "geotabId": 0,
                "xacc": 0,
                "yacc": 0,
                "zacc": 0,
                "x": 0,
                "y": 0
            ]
        ]

        // URLRequest 객체 정의
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"

        // 멀티파트 데이터 생성
        let boundary = UUID().uuidString
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")


        var body = Data()

        // 이미지 데이터 추가
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        // 파라미터 데이터 추가
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // HTTP 요청 본문 설정
        request.httpBody = body

        // URLSession 객체를 통해 전송, 응답값 처리
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle the server response here
            if let error = error {
                print("Error: \(error)")
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Response Status Code: \(httpResponse.statusCode)")
                    if let data = data {
                        if httpResponse.statusCode == 200 {
                            do {
                                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                    let code = jsonResponse["code"] as? String ?? ""
                                    let message = jsonResponse["message"] as? String ?? ""
                                    let responseData = jsonResponse["data"] as? [String: Any] ?? [:]

                                    // Handle the received data, code, and message here
                                    print("Received Data: \(responseData)")
                                    print("Response Code: \(code)")
                                    print("Response Message: \(message)")

                                    // You can further process responseData, code, and message as needed
                                } else {
                                    print("Error decoding JSON response.")
                                }
                            } catch {
                                print("Error decoding JSON response: \(error)")
                            }
                        } else {
                            // Handle non-200 status code errors here
                            let responseString = String(data: data, encoding: .utf8)
                            print("Non-200 Response Data: \(responseString ?? "")")
                        }
                    }
                }
            }
        }
        task.resume()
    }

}
