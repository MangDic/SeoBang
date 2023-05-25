//
//  RankCell.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/17.
//

import UIKit

class RankCell: UITableViewCell {
    static let id = "RankCell"
    
    lazy var containerView = UIView().then {
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.backgroundColor = #colorLiteral(red: 0.9823737741, green: 0.8417647481, blue: 0.8100860715, alpha: 1)
    }
    
    lazy var rankBox = UILabel().then {
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.textAlignment = .center
        $0.backgroundColor = #colorLiteral(red: 1, green: 0.7640555501, blue: 0.6806686521, alpha: 1)
        $0.textColor = .white
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 14)
    }
    
    lazy var nickNameLabel = UILabel().then {
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 14)
        $0.textColor = .white
    }
    
    lazy var stepsLabel = UILabel().then {
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 14)
        $0.textColor = .white
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(item: Rank, rank: Int, type: RankType) {
        rankBox.text = "\(rank)"
        stepsLabel.text = "\(item.getScore()) Points"
        
        switch type {
        case .region:
            nickNameLabel.text = item.region
            if item.region == UserInfoService.shared.region {
                containerView.layer.borderColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
            }
            else {
                containerView.layer.borderColor = #colorLiteral(red: 0.9879724383, green: 1, blue: 1, alpha: 0)
            }
        case .individual:
            nickNameLabel.text = item.nickName + " [\(item.region)]"
            if item.uuid == UserInfoService.shared.uuid {
                containerView.layer.borderColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
            }
            else {
                containerView.layer.borderColor = #colorLiteral(red: 0.9879724383, green: 1, blue: 1, alpha: 0)
            }
        }
    }
    
    private func setupLayout() {
        contentView.backgroundColor = .white
        
        contentView.addSubview(containerView)
        containerView.addSubviews([rankBox,
                                   nickNameLabel,
                                   stepsLabel])
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(3)
            $0.height.equalTo(60)
        }
        
        rankBox.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(30)
        }
        
        nickNameLabel.snp.makeConstraints {
            $0.leading.equalTo(rankBox.snp.trailing).offset(15)
            $0.top.bottom.equalTo(rankBox)
        }
        
        stepsLabel.snp.makeConstraints {
            $0.top.bottom.equalTo(rankBox)
            $0.leading.equalTo(nickNameLabel.snp.trailing).offset(5)
            $0.trailing.equalToSuperview().inset(15)
        }
    }
}

