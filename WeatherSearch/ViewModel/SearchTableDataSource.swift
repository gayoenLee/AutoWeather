//
//  Untitled.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/7/24.
//

import UIKit

//final class SearchTableDataSource: NSObject, UITableViewDataSource {
//    private var cities: [City] = []
//    
//    func updateCities(_ cities: [City]) {
//        
//        self.cities = cities
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        cities.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCityCell", for: indexPath) as? CustomCityCell else { return  UITableViewCell()}
//        let city = cities[indexPath.row]
//        cell.configure(cityName: city.name, country: city.country)
//        return cell
//    }
//}
//
//final class SearchTableDelegate: NSObject, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("셀 선택: \(indexPath.row)")
//    }
//}
