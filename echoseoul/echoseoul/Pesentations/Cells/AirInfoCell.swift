//
//  AirInfoCell.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/18.
//

import UIKit

class AirInfoCell: UICollectionViewCell {
    static let id = "AirInfoCell"
    
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
    
    func configure(item: Weather) {
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
    
    private func setBackgroundColor(item: Weather) {
        var color = #colorLiteral(red: 1, green: 0.4956962466, blue: 0.6213060021, alpha: 1)
        let value = item.value
        switch item.name {
        case "미세먼지":
            if value < 31 {
                color = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            }
            else if value < 70 {
                color = #colorLiteral(red: 0.4044137001, green: 0.4625090361, blue: 0.8461126685, alpha: 1)
            }
        case "초미세먼지":
            if value < 16 {
                color = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            }
            else if value < 36 {
                color = #colorLiteral(red: 0.4044137001, green: 0.4625090361, blue: 0.8461126685, alpha: 1)
            }
        case "일산화탄소":
            if value < 2.1 {
                color = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            }
            else if value < 9.01 {
                color = #colorLiteral(red: 0.4044137001, green: 0.4625090361, blue: 0.8461126685, alpha: 1)
            }
        default:
            if value < 0.03 {
                color = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            }
            else if value < 0.091 {
                color = #colorLiteral(red: 0.4044137001, green: 0.4625090361, blue: 0.8461126685, alpha: 1)
            }
        }
        contentView.backgroundColor = color
    }
}
