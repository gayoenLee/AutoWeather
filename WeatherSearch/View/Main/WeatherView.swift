//
//  WeatherView.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/5/24.
//

import SnapKit
import UIKit


protocol WeatherViewDelegate: UICollectionViewDelegateFlowLayout {
    
}

protocol WeatherViewDataSource: UICollectionViewDataSource {
    
}

final class WeatherView: UIView {
    
    weak var delegate: WeatherViewDelegate? {
        didSet { self.collectionView.delegate = self.delegate }
    }
    
    weak var dataSource: WeatherViewDataSource? {
        didSet { self.collectionView.dataSource = self.dataSource}
    }
    
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let activityIndicator = UIActivityIndicatorView(style: .large) // 로딩 인디케이터
    
    let searchBar = UISearchBar()
    private let containerView = UIView() // SearchBar 아래에 들어갈 컨테이너 뷰
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSearchBar()
        setupContainerView()
        setupCollectionView()
        setupIndicator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSearchBar() {
        addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    
    private func setupCollectionView() {
        collectionView = WeatherViewFactory.createCollectionView()
        
        containerView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()  // containerView 내에서 꽉 차도록 설정
        }
    }
    
    private func setupIndicator(){
        // 로딩 인디케이터
        activityIndicator.hidesWhenStopped = true
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // ContainerView 설정 (SearchBar 아래 뷰들만 교체)
    private func setupContainerView() {
        addSubview(containerView)
        containerView.backgroundColor = .bgColor
        containerView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)  // 안전영역까지 containerView가 확장되도록 수정
        }
    }
    
}
