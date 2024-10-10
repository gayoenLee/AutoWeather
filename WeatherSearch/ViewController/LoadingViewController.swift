//
//  LoadingViewController.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/11/24.
//

import Foundation
import UIKit
import SnapKit
import RxSwift

class LoadingViewController: UIViewController {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "rain")
        return imageView
    }()
    
    private let disposeBag = DisposeBag()

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        //setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startImageAnimation()
    }
    
    private func setupUI() {
           view.addSubview(imageView)
           
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
       }
       
       private func startImageAnimation() {
           // 애니메이션에 사용할 이미지 배열 설정
           let imageNames = ["clouds", "fog", "rain", "sunny"]
           var images: [UIImage] = []
           
           for name in imageNames {
               if let image = UIImage(named: name) {
                   images.append(image)
               }
           }
           
           // 이미지 뷰에 애니메이션 이미지 설정
           imageView.animationImages = images
           imageView.animationDuration = 5.0 // 애니메이션 지속 시간 (2초 동안 이미지 순환)
           imageView.animationRepeatCount = 0 // 0이면 무한 반복
           
           // 애니메이션 시작
           imageView.startAnimating()
       }
    
       
       func stopLoading() {
           // 로딩이 완료되면 애니메이션과 인디케이터 중지
           imageView.stopAnimating()
       }
}
