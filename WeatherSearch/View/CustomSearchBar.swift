//
//  CustomSearchBar.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/11/24.
//

import Foundation
import UIKit
import SnapKit


final class CustomSearchBar: UISearchBar {
    
    override init(frame: CGRect) {
           super.init(frame: frame)
           setupSearchBar()
       }
       
       required init?(coder: NSCoder) {
           super.init(coder: coder)
           setupSearchBar()
       }
       
       private func setupSearchBar() {
           // 배경 색상 설정
           self.backgroundImage = UIImage() // 기본 배경 이미지 제거
           self.barTintColor = UIColor.clear
           self.searchBarStyle = .minimal
           
           if let textField = self.value(forKey: "searchField") as? UITextField {
               textField.backgroundColor = .txtFieldColor
               textField.textColor = .darkGray
               textField.font = UIFont.systemFont(ofSize: 16)
               textField.layer.cornerRadius = 20
               textField.clipsToBounds = true
               textField.attributedPlaceholder = NSAttributedString(
                   string: "Search",
                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
               )
               
               let iconView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
               iconView.tintColor = .lightGray
               textField.leftView = iconView
               textField.leftViewMode = .always
               textField.textAlignment = .center
           }
       }
   }
