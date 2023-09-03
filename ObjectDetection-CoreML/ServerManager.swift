////
////  ServerManager.swift
////  ObjectDetection-CoreML
////
////  Created by 정서연 on 2023/08/29.
////  Copyright © 2023 tucan9389. All rights reserved.
////
//
//import Foundation
//
//class ServerManager {
//    static let shared = ServerManager()
//
//    private init() {}
//
//    func sendImageToServer(imageData: Data, completion: @escaping (Error?) -> Void) {
//        // Create URL object and configure the request
//        guard let url = URL(string: "https://your-server-url.com/api/upload") else {
//            completion(NSError(domain: "InvalidURL", code: 0, userInfo: nil))
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        // Configure request headers and body
//        let boundary = "Boundary-\(UUID().uuidString)"
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        
//        var body = Data()
//        body.append("--\(boundary)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
//        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
//        body.append(imageData)
//        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
//        
//        request.httpBody = body
//        
//        // Create a URLSessionDataTask for sending the request
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                completion(error)
//                return
//            }
//            
//            // Process the response if needed
//            
//            completion(nil)
//        }
//        
//        // Start the URLSessionDataTask
//        task.resume()
//    }
//}
