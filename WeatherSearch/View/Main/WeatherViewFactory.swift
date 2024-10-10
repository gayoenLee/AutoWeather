//
//  WeatherViewFactory.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/10/24.
//

import Foundation
import UIKit

final class WeatherViewFactory {
    
    static func createSearcuBar() -> UISearchBar {
        let searchBar = UISearchBar()
        return searchBar
    }
    
    static func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        //layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        // UICollectionView 생성
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
                
        // 셀 등록
        collectionView.register(CityTodayInfoCell.self, forCellWithReuseIdentifier: "CityTodayInfoCell")
        collectionView.register(HourlyWeatherCell.self, forCellWithReuseIdentifier: "HourlyWeatherCell")
        collectionView.register(FiveDayInfoCell.self, forCellWithReuseIdentifier: "FiveDayInfoCell")
        collectionView.register(MapViewCell.self, forCellWithReuseIdentifier: "MapViewCell")
        collectionView.register(GridWeatherView.self, forCellWithReuseIdentifier: "GridWeatherView")
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .bgColor
        return collectionView
    }
}
