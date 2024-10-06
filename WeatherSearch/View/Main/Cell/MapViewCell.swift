//
//  CurrentLocationCell.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/6/24.
//

import UIKit
import SnapKit
import MapKit

final class MapViewCell: UICollectionViewCell {
    
    private let mapView = MKMapView()
    private let title : UILabel = {
        let label = UILabel()
        label.text = "지도"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(title)
        setupMapView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMapView() {
        
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        /*
          최초 데이터 기준  “{"id":1839726,"name":"Asan","country":"KR","coord":{"lon":127.004173,"lat":36.783611}} 로 표시
         */
        //초기 위치 설정
        let initialLocation = CLLocation(latitude: 36.783611, longitude: 127.004173)
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
        contentView.addSubview(mapView)
    }
    
    private func setupConstraints() {
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview()
        }
    }
    
    func addMarker(at coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }

}
