//
//  HealthDataView.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/19.

import Foundation
import UIKit
import RxCocoa
import RxSwift

class HealthDataView: UIView {
    var disposeBag = DisposeBag()
    
    let cellCount: CGFloat = 3
    let cellSpacing: CGFloat = 2
    let healthRelay = BehaviorRelay<[Weather]>(value: [])
    
    let flowLayout = UICollectionViewFlowLayout()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
        $0.backgroundColor = .white
        $0.register(MyHealthCell.self, forCellWithReuseIdentifier: MyHealthCell.id)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func bind() {
        collectionView.delegate = self
        
        HealthService.shared.healthDataRelay
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(cellIdentifier: MyHealthCell.id)) { row, item, cell in
                guard let cell = cell as? MyHealthCell else { return }
                cell.configure(item: item)
            }.disposed(by: disposeBag)
    }
}

extension HealthDataView: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = (collectionView.frame.width - cellSpacing * (cellCount - 1)) / cellCount
        return CGSize(width: width , height: 50 )
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
}


