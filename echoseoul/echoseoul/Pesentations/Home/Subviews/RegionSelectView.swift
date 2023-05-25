//
//  RegionSelectView.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/17.
//
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class RegionSelectView: UIView {
    var disposeBag = DisposeBag()
    
    let selectedRelay = PublishRelay<String>()
    
    let badArr = ["오늘은 쉴까요?", "이런, 날씨가 좋지 않아요 :(", "내일은 날씨가 좋을거에요"]
    let sosoArr = ["걷기 무난한 날씨에요!", "오늘도 파이팅!", "산책 어때요?"]
    let goodArr = ["걷기 좋아요!", "날씨도 좋은데 잠깐 걸을까요?", "날씨가 환상!"]
    
    lazy var stateLabel = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        $0.font = UIFont(name: "Cafe24-Ohsquareair", size: 20)
    }
    
    lazy var tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.register(RegionCell.self, forCellReuseIdentifier: RegionCell.id)
        $0.rowHeight = UITableView.automaticDimension
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
        backgroundColor = .white
        
        addSubviews([stateLabel, tableView])
        
        stateLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(stateLabel.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview().inset(10)
        }
    }
    
    private func bind() {
        AirInfoService.shared.cityRelay
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: RegionCell.id)) { row, item, cell in
                guard let cell = cell as? RegionCell else { return }
                cell.configure(item: item)
            }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(String.self)
            .subscribe(onNext: { [weak self] city in
                guard let `self` = self else { return }
                self.selectedRelay.accept(city)
            }).disposed(by: disposeBag)
    }
}

class RegionCell: UITableViewCell {
    static let id = "RegionCell"
    
    lazy var cityLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont(name: "Cafe24Ohsquareair", size: 14)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(item: String) {
        cityLabel.text = item
    }
    
    private func setupLayout() {
        contentView.backgroundColor = .white
        contentView.addSubview(cityLabel)
        
        cityLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
    }
}
