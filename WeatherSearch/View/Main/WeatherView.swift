//
//  WeatherView.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/5/24.
//

import SnapKit
import UIKit


protocol WeatherViewDelegate: UICollectionViewDelegate {
    
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
    
    
    private let collectionView = UICollectionView(frame: .zero)
    
}
