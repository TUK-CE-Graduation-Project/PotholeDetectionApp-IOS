//
//  LoadingViewController.swift
//  ObjectDetection-CoreML
//
//  Created by 정서연 on 2023/09/01.
//  Copyright © 2023 tucan9389. All rights reserved.
//

import UIKit


class LoadingViewController: UIViewController {

    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        // 스토리보드 또는 XIB에서 메인 뷰 컨트롤러를 인스턴스화합니다.
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // "Main"을 실제 스토리보드 이름으로 대체하십시오.
        if let viewController = storyboard.instantiateViewController(withIdentifier: "ViewControllerIdentifier") as? ObjectDetectingViewController {
            // "ViewControllerIdentifier"는 실제 스토리보드 또는 XIB에서 설정한 식별자로 대체해야 합니다.
            
            // 메인 뷰 컨트롤러를 현재 네비게이션 컨트롤러의 스택에 푸시합니다.
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 지도 로고를 표시할 이미지 뷰 생성
        let mapLogoImageView = UIImageView(image: UIImage(named: "map_logo"))
        mapLogoImageView.contentMode = .scaleAspectFit
        mapLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapLogoImageView)

        // 이미지 뷰를 중앙에 배치하기 위한 제약 조건 추가
        NSLayoutConstraint.activate([
            mapLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mapLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mapLogoImageView.widthAnchor.constraint(equalToConstant: 200), // 필요한 경우 너비 조정
            mapLogoImageView.heightAnchor.constraint(equalToConstant: 200) // 필요한 경우 높이 조정
        ])

        // 필요한 경우 배경색 또는 다른 UI 요소를 추가할 수 있습니다
        view.backgroundColor = UIColor.white // 이 예제에서는 배경색을 흰색으로 설정
    }
}
