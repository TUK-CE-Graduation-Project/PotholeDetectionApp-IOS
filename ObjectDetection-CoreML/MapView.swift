//
//  MapView.swift
//  ObjectDetection-CoreML
//
//  Created by 정서연 on 2023/09/03.
//  Copyright © 2023 tucan9389. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import SnapKit


class MapViewUI: UIView {

    let myLocationButton = UIButton()
    let startDrivingButton = UIButton()
    let map = MKMapView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(map)
        self.addSubview(myLocationButton)
        self.addSubview(startDrivingButton)
        configure()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure() {
        myLocationButton.setTitle("내 위치로 가기", for: .normal)
        myLocationButton.backgroundColor = .darkGray
        myLocationButton.setTitleColor(.yellow, for: .normal)
        myLocationButton.layer.cornerRadius = 12
        
        startDrivingButton.setTitle("주행 시작하기", for: .normal) // 주행 시작하기 버튼 속성 설정
        startDrivingButton.backgroundColor = .darkGray
        startDrivingButton.setTitleColor(.white, for: .normal)
        startDrivingButton.layer.cornerRadius = 12
    }
    
    func makeConstraints() {
        map.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        myLocationButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(startDrivingButton.snp.top).offset(-20)
            make.height.equalTo(50)
        }
        
        startDrivingButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
    }
}
