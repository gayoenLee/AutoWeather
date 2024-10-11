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
        label.text = "위치"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.textColor = .white
        return label
    }()
    var location: MapLocationData?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(title)
        contentView.addSubview(mapView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMapView() {
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        guard let location = location else { return }
        let initialLocation = CLLocation(latitude: Double(location.lat)!, longitude: Double(location.lon)!)
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
        addMarker(at: CLLocationCoordinate2D(latitude: Double(location.lat)!, longitude:Double(location.lon)!))
        
        backgroundColor = .cellBgColor
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
    func configure(with coordData: MapLocationData) {
        self.location = coordData
        setupMapView()

    }
    
    private func setupConstraints() {
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    
    
    private func addMarker(at coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }

}
