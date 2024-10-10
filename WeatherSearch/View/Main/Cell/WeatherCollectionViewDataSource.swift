//
//  WeatherCollectionViewDataSource.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/10/24.
//

import Foundation
import UIKit

final class WeatherCollectionViewDataSource: NSObject, WeatherViewDelegate, WeatherViewDataSource {
    var fullWeatherData: FullWeatherData?
 
    func update(with newData: FullWeatherData) {
         // 새로운 데이터를 받아서 fullWeatherData를 업데이트
         self.fullWeatherData = newData
     }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //        return CGSize(width: collectionView.frame.width*0.9, height: 80)
        let width = collectionView.bounds.width
        switch indexPath.item {
        case 0:
            return CGSize(width: width, height: 250) // City Info
        case 1:
            return CGSize(width: width, height: 150) // Hourly Weather
        case 2:
            return CGSize(width: width, height: 250)
        case 3:
            return CGSize(width: width, height: width) // Five Day Forecast
        case 4:
            return CGSize(width: width, height: width) // Five Day Forecast
        default:
            return CGSize(width: collectionView.bounds.width, height: 100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityTodayInfoCell", for: indexPath) as! CityTodayInfoCell
            
            if let data = fullWeatherData?.todayCityInfo {
                cell.configure(with: data)
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyWeatherCell", for: indexPath) as! HourlyWeatherCell
            //이틀치의 데이터만 전달
            if let data = fullWeatherData?.threeHourData {
                print("데이터 전달")
                cell.configure(with: data)
            }
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FiveDayInfoCell", for: indexPath) as! FiveDayInfoCell
            if let data = fullWeatherData?.dailyWeatherData
            {
                cell.configure(with: data)
            }
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MapViewCell", for: indexPath) as! MapViewCell
            if let data = fullWeatherData?.mapLocationData {
                cell.configure(with: data)
            }
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridWeatherView", for: indexPath) as! GridWeatherView
            if let averageData = fullWeatherData?.averageData {
                cell.configure(data: averageData)
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityTodayInfoCell", for: indexPath) as! CityTodayInfoCell
            return cell
        }
    }
}
