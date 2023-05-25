//
//  MyHealthCell.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/19.
//

import UIKit

class MyHealthCell: UICollectionViewCell {
    static let id = "MyHealthCell"
    
    lazy var nameLabel = UILabel().then {
        $0.textAlignment = .left
        $0.textColor = .white
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 12)
    }
    
    lazy var valueLabel = UILabel().then {
        $0.textAlignment = .right
        $0.textColor = .white
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 10)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(item: Health) {
        nameLabel.text = item.name
        valueLabel.text = "\(item.value)"
        setBackgroundColor(item: item)
    }
    
    private func setupLayout() {
        contentView.layer.cornerRadius = 4
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        contentView.addSubviews([nameLabel, valueLabel])
        
        nameLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview().inset(10)
        }
        
        valueLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
            $0.leading.trailing.bottom.equalToSuperview().inset(10)
        }
    }
    
    private func setBackgroundColor(item: Health) {
        var color = #colorLiteral(red: 1, green: 0.7975910902, blue: 0.7020506859, alpha: 1)
        switch item.name {
        case "걸음":
            color = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        case "이동 거리":
            color = #colorLiteral(red: 1, green: 0.6035473943, blue: 0.7334902883, alpha: 1)
        default:
            color = #colorLiteral(red: 0.756557405, green: 0.6431825757, blue: 1, alpha: 1)
        }
        contentView.backgroundColor = color
    }
}

