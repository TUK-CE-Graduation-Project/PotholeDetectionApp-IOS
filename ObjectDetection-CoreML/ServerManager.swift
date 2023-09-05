//
//  ServerManager.swift
//  ObjectDetection-CoreML
//
//  Created by 정서연 on 2023/08/29.
//  Copyright © 2023 tucan9389. All rights reserved.
//


//import Foundation
//import UIKit
//import Alamofire
//
//class ServerManager {
//    // 공유 싱글톤 인스턴스 정의
//    static let shared = ServerManager()
//
//    // URL 객체 정의
//    let url = URL(string: "http://18.207.198.224:8080/api/pothole/register")!
//
//    private init() {
//        // 싱글톤 패턴을 적용하기 위한 프라이빗 초기화 메서드
//    }
//
//    func registerPothole(image: UIImage) {
//        let boundary = UUID().uuidString
//
//        // JSON 데이터 생성
//        let dataDictionary: [String: Any] = [
//            "geotabId": 4,
//            "xacc": 0.0,
//            "yacc": 0.0,
//            "zacc": 0.0,
//            "x": 37.5222794235,
//            "y": 127.069069813,
//        ]
//
//        // URLRequest 객체 정의
//        var request = URLRequest(url: self.url)
//        request.httpMethod = "POST"
//
//        // HTTP 메시지 헤더 설정
//        request.setValue("multipart/form-data;", forHTTPHeaderField: "Content-Type")
//
//        // HTTP 본문 데이터 생성
//        var body = Data()
//
//        print("Before HTTP Body Size: \(body.count) bytes")
//
//
//        // JSON 데이터 추가
//        body.append("--\(boundary)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"data\"\r\n".data(using: .utf8)!)
//        body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
//        if let jsonData = try? JSONSerialization.data(withJSONObject: dataDictionary) {
//            body.append(jsonData)
//        }
//
//        // 이미지 데이터 추가
//        appendImagePart(image: image, boundary: boundary, body: &body)
//
//        // 멀티파트 form-data 마무리
//        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
//
//        // HTTP 본문 데이터 설정
//        request.httpBody = body
//
//
//        print("After HTTP Body Size: \(body.count) bytes")
//
//
//        // Alamofire를 사용하여 요청 보내기
//        AF.upload(multipartFormData: { multipartFormData in
//            // JSON 데이터를 추가
//            for (key, value) in dataDictionary {
//                if let data = "\(value)".data(using: .utf8) {
//                    multipartFormData.append(data, withName: key)
//                }
//            }
//
//            // 이미지 데이터를 추가
//            if let imageData = image.jpegData(compressionQuality: 0.8) {
//                multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
//            }
//        }, with: request)
//        .responseJSON { response in
//            switch response.result {
//            case .success(let data):
//                if let jsonResponse = data as? [String: Any] {
//                    let code = jsonResponse["code"] as? String ?? ""
//                    let message = jsonResponse["message"] as? String ?? ""
//                    let responseData = jsonResponse["data"] as? [String: Any] ?? [:]
//
//                    // 서버 응답 데이터 처리
//                    print("받은 데이터: \(responseData)")
//                    print("응답 코드: \(code)")
//                    print("응답 메시지: \(message)")
//                } else {
//                    print("JSON 응답 해독 오류.")
//                }
//            case .failure(let error):
//                print("오류: \(error)")
//            }
//        }
//    }
//
//
//    // 이미지를 본문에 추가하는 함수
//    private func appendImagePart(image: UIImage, boundary: String, body: inout Data) {
//        if let imageData = image.jpegData(compressionQuality: 0.8) {
//            body.append("--\(boundary)\r\n".data(using: .utf8)!)
//            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
//            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
//            body.append(imageData)
//            body.append("\r\n".data(using: .utf8)!)
//        }
//    }
//}


//import Foundation
//import UIKit
//import Alamofire
//
//class ServerManager {
//    static let shared = ServerManager()
//
//    // URL object definition
//    let url = URL(string: "http://18.207.198.224:8080/api/pothole/register")!
//
//
//    private init() {
//        // Private initialization method to enforce the singleton pattern
//    }
//
//    func registerPothole(image: UIImage) {
//        let boundary = UUID().uuidString
//
//        // Generate JSON data
//        let dataDictionary: [String: Any] = [
//            "data": [
//                "geotabId": 4,
//                "xacc": 0.0,
//                "yacc": 0.0,
//                "zacc": 0.0,
//                "x": 37.5222794235,
//                "y": 127.069069813,
//            ],
//        ]
//        let jsonData = try! JSONSerialization.data(withJSONObject: dataDictionary, options: [])
//
//        // URLRequest object definition
//        var request = URLRequest(url: self.url)
//        request.httpMethod = "POST"
//
//        // Set HTTP message headers
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        // Generate HTTP body data
//        var body = Data()
//
//        // Add JSON data
//        body.append("--\(boundary)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"data\"\r\n".data(using: .utf8)!)
//        body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
//        body.append(jsonData)
//
//        for (key, value) in dataDictionary {
//            body.append(boundary.data(using: .utf8)!)
//            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
//            body.append("\(value)\r\n".data(using: .utf8)!)
//        }
//        body.append("\r\n".data(using: .utf8)!)
//
//        // add image data
//        print("Before appending image data: Body Length = \(body.count)")
//        appendImagePart(image: image, boundary: boundary, body: &body)
//        print("After appending image data: Body Length = \(body.count)")
//        // Display multipart finish
//        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
//
//
//        // Set HTTP body data
//        request.httpBody = body
//
//
//        // Send and handle response using URLSession
//
//        let session = URLSession(configuration: .default)
//        session.configuration.timeoutIntervalForRequest = TimeInterval(20)
//        session.configuration.timeoutIntervalForResource = TimeInterval(20)
//
//        let task = session.uploadTask(with: request, from: body) { (data, response, error) in
//            DispatchQueue.main.async {
//                if let error = error {
//                    print("Error: \(error)")
//
//                }
//                if let httpResponse = response as? HTTPURLResponse {
//                    print("HTTP response status code: \(httpResponse.statusCode)")
//                    if let data = data {
//                        if httpResponse.statusCode == 200 {
//                            do {
//                                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                                    let code = jsonResponse["code"] as? String ?? ""
//                                    let message = jsonResponse["message"] as? String ?? ""
//                                    let responseData = jsonResponse["data"] as? [String: Any] ?? [:]
//
//                                    print("Data received: \(responseData)")
//                                    print("Response code: \(code)")
//                                    print("Response message: \(message)")
//
//                                } else {
//                                    print("JSON response decoding error.")
//                                }
//                            } catch {
//                                print("JSON response decoding error: \(error)")
//                            }
//                        } else {
//                            // Handle status code errors other than 200
//                            let responseString = String(data: data, encoding: .utf8)
//                            print("Response data other than 200: \(responseString ?? "")")
//                        }
//                    }
//                }
//            }
//        }
//    }
//    private func appendImagePart(image: UIImage, boundary: String, body: inout Data) {
//        if let imageData = image.jpegData(compressionQuality: 0.8) {
//            body.append("--\(boundary)\r\n".data(using: .utf8)!)
//            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
//            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
//            body.append(imageData)
//            body.append("\r\n".data(using: .utf8)!)
//        }
//    }
//}
//


import Foundation
import UIKit

class ServerManager {
    // define shared singleton instance
    static let shared = ServerManager()
    
    // URL object definition
    let url = URL(string: "http://18.207.198.224:8080/api/pothole/register")!


    private init() {
        // Private initialization method to enforce the singleton pattern
    }

    func registerPothole(image: UIImage) {
        let boundary = UUID().uuidString

        // Generate JSON data
        let dataDictionary: [String: Any] = [
            "data": [
                "geotabId": 4,
                "xacc": 1.0,
                "yacc": 0.0,
                "zacc": 0.0,
                "x": 37.5222794235,
                "y": 127.069069813
            ],
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: dataDictionary, options: [])

        // URLRequest object definition
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"

        // Set HTTP message headers
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Generate HTTP body data
        var body = Data()
        print("Before appending image data: Body Length = \(body.count)")
        
                // Add JSON data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"data\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
        body.append(jsonData)
        
        for (key, value) in dataDictionary {
            body.append(boundary.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        body.append("\r\n".data(using: .utf8)!)
        
                // add image data
        print("Before appending image data: Body Length = \(body.count)")
        appendImagePart(image: image, boundary: boundary, body: &body)
        print("After appending image data: Body Length = \(body.count)")
                // Display multipart finish
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        
                // Set HTTP body data
        request.httpBody = body
        
        print("After appending image data: Body Length = \(body.count)")
        
        // Send and handle response using URLSession
        
        let session = URLSession(configuration: .default)
        session.configuration.timeoutIntervalForRequest = TimeInterval(20)
        session.configuration.timeoutIntervalForResource = TimeInterval(20)
        
        let task = session.uploadTask(with: request, from: body) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error)")

                }
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP response status code: \(httpResponse.statusCode)")
                    if let data = data {
                        if httpResponse.statusCode == 200 {
                            do {
                                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                    let code = jsonResponse["code"] as? String ?? ""
                                    let message = jsonResponse["message"] as? String ?? ""
                                    let responseData = jsonResponse["data"] as? [String: Any] ?? [:]

                                    // Process received data, code and messages
                                    print("Data received: \(responseData)")
                                    print("Response code: \(code)")
                                    print("Response message: \(message)")

                                    // ResponseData, code, message, etc. can be further processed as needed.
                                } else {
                                    print("JSON response decoding error.")
                                }
                            } catch {
                                print("JSON response decoding error: \(error)")
                            }
                        } else {
                            // Handle status code errors other than 200
                            let responseString = String(data: data, encoding: .utf8)
                            print("Response data other than 200: \(responseString ?? "")")
                        }
                    }
                }
            }
        }
        task.resume()
    }

    // Function to add image to body
    private func appendImagePart(image: UIImage, boundary: String, body: inout Data) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        print(String(data: body, encoding: .utf8) ?? "Body data is empty")

    }
    
}
