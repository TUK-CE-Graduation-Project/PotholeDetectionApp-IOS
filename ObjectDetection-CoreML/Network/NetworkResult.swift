//
//  NetworkResult.swift
//  ObjectDetection-CoreML
//
//  Created by 정서연 on 2023/05/20.
//  Copyright © 2023 tucan9389. All rights reserved.
//

enum NetworkResult<T>{
    case success(T)
    case requestErr(T)
    case pathErr(T)
    case serverErr(T)
    case networkFail(T)
}
