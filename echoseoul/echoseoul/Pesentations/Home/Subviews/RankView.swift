//
//  RankView.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/23.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class RankView: UIView {
    var disposeBag = DisposeBag()
    
    let selectRelay = BehaviorRelay<RankType>(value: .region)
    
    lazy var buttonStack = UIStackView().then {
        $0.distribution = .fillEqually
    }
    
    lazy var regionButton = UIButton().then {
        $0.titleLabel?.font = UIFont(name: "Cafe24Ohsquare", size: 14)
        $0.setTitleColor(.black, for: .normal)
        $0.setTitle("지역별", for: .normal)
        $0.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.selectRelay.accept(.region)
            self.scrollToTop()
        }).disposed(by: disposeBag)
    }
    
    lazy var individualButton = UIButton().then {
        $0.titleLabel?.font = UIFont(name: "Cafe24Ohsquare", size: 14)
        $0.setTitleColor(.darkGray, for: .normal)
        $0.setTitle("개인별", for: .normal)
        $0.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.selectRelay.accept(.individual)
            self.scrollToTop()
        }).disposed(by: disposeBag)
    }
    
    lazy var tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.backgroundColor = .white
        $0.register(RankCell.self, forCellReuseIdentifier: RankCell.id)
        $0.estimatedRowHeight = UITableView.automaticDimension
    }
    
    lazy var myRankLabel = UILabel().then {
        $0.textAlignment = .right
        $0.textColor = .black
        $0.font = UIFont(name: "Cafe24-Ohsquareair", size: 14)
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
        layer.borderWidth = 2
        layer.borderColor = #colorLiteral(red: 0.8958532214, green: 0.9071309566, blue: 0.906932652, alpha: 1)
        layer.cornerRadius = 8
        addSubviews([buttonStack,
                     tableView,
                     myRankLabel])
        
        buttonStack.addArrangedSubview(regionButton)
        buttonStack.addArrangedSubview(individualButton)
        
        buttonStack.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(20)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(buttonStack.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        
        myRankLabel.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(4)
            $0.leading.bottom.trailing.equalToSuperview().inset(10)
        }
    }
    
    private func bind() {
//        RankService.shared.dataRelay
//            .filter { !$0.isEmpty }
//            .take(1)
//            .observe(on: MainScheduler.asyncInstance)
//            .subscribe(onNext: { [weak self] _ in
//                guard let `self` = self else { return }
//                self.selectRelay.accept(.region)
//            }).disposed(by: disposeBag)
        
        RankService.shared.dataRelay
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: RankCell.id)) { [weak self] row, item, cell in
                guard let `self` = self else { return }
                guard let cell = cell as? RankCell else { return }
                cell.configure(item: item, rank: row + 1, type: self.selectRelay.value)
            }.disposed(by: disposeBag)
        
        selectRelay
            .bind(to: RankService.shared.selectRelay)
            .disposed(by: disposeBag)
        
        selectRelay.subscribe(onNext: { [weak self] type in
            guard let `self` = self else { return }
            switch type {
            case .region:
                self.regionButton.setTitleColor(.black, for: .normal)
                self.individualButton.setTitleColor(.lightGray, for: .normal)
                let rank = RankService.shared.findRegionRank()
                self.myRankLabel.text = "우리 지역 순위: \(rank)위"
            case .individual:
                self.individualButton.setTitleColor(.black, for: .normal)
                self.regionButton.setTitleColor(.lightGray, for: .normal)
                let rank = RankService.shared.findIndividualRank()
                self.myRankLabel.text = "나의 순위: \(rank)위"
            }
        }).disposed(by: disposeBag)
    }
    
    func scrollToTop() {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                              at: .top,
                              animated: false)
    }
}

enum RankType {
    case region
    case individual
}
