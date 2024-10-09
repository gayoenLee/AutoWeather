//
//  CollectionBinder.swift
//  WeatherSearch
//
//  Created by 이은호 on 10/9/24.
//

import RxSwift
import RxCocoa
import UIKit

final class CollectionBinder<T> {
    
    private let disposeBag = DisposeBag()
    
    func bindCollectionView<Cell: UICollectionViewCell>(
        data: Observable<T>,
        to collectionView: UICollectionView,
        configureCell: @escaping (T, Cell) -> Void
    ) {
        data
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { value in
                if let indexPaths = collectionView.indexPathsForVisibleItems.first,
                   let cell = collectionView.cellForItem(at: indexPaths) as? Cell {
                    configureCell(value, cell)
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    
    
}
