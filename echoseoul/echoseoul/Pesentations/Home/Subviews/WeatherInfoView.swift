//
//  WeatherInfoView.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/17.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class WeatherInfoView: UIView {
    var disposeBag = DisposeBag()
    
    let cellCount: CGFloat = 4
    let cellSpacing: CGFloat = 4
    let weatherRelay = BehaviorRelay<[Weather]>(value: [])
    
    let badArr = ["오늘은 쉴까요?", "이런, 날씨가 좋지 않아요 :(", "내일은 날씨가 좋을거에요"]
    let sosoArr = ["걷기 무난한 날씨에요!", "오늘도 파이팅!", "산책 어때요?"]
    let goodArr = ["걷기 좋아요!", "날씨도 좋은데 잠깐 걸을까요?", "날씨가 환상!"]
    
    lazy var stateLabel = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        $0.font = UIFont(name: "Cafe24-Ohsquareair", size: 20)
    }
    
    let flowLayout = UICollectionViewFlowLayout()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
        $0.backgroundColor = .white
        $0.register(AirInfoCell.self, forCellWithReuseIdentifier: AirInfoCell.id)
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
        addSubviews([stateLabel, collectionView])
        
        stateLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(stateLabel.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(50)
        }
    }
    
    private func bind() {
        collectionView.delegate = self
        
        AirInfoService.shared.airInfoRelay
            .bind(to: weatherRelay).disposed(by: disposeBag)
        
        weatherRelay.asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(cellIdentifier: AirInfoCell.id)) { row, item, cell in
                guard let cell = cell as? AirInfoCell else { return }
                cell.configure(item: item)
            }.disposed(by: disposeBag)
    }
    
    func updateStateLabel(state: String) {
        var color = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        var arr = [String]()
        switch state {
        case "좋음":
            arr = goodArr
            color = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        case "보통":
            arr = sosoArr
            color = #colorLiteral(red: 1, green: 0.6787490249, blue: 0.5300305486, alpha: 1)
        default:
            arr = badArr
        }
        
        DispatchQueue.main.async {
            let rand = Int.random(in: 0..<arr.count)
            self.stateLabel.text = arr[rand]
            self.stateLabel.textColor = color
        }
    }
}

extension WeatherInfoView: UICollectionViewDelegateFlowLayout{
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

struct Weather {
    let name: String
    let value: Double
}
