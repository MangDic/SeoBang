//
//  PlaceCell.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/18.
//

import UIKit

class PlaceCell: UITableViewCell {
    static let id = "PlaceCell"
    
    lazy var placeNameLabel = UILabel().then {
        $0.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 14)
    }
    
    lazy var addressLabel = UILabel().then {
        $0.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        $0.font = UIFont(name: "Cafe24-Ohsquareair", size: 14)
    }
    
    lazy var distanceLabel = UILabel().then {
        $0.textAlignment = .right
        $0.textColor = .black
        $0.font = UIFont(name: "Cafe24-Ohsquareair", size: 12)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(item: Place) {
        self.placeNameLabel.text = item.facName
        self.addressLabel.text = item.addr
        self.distanceLabel.text = "\(round(item.distance / 10) / 10)Km"
    }
    
    private func setupLayout() {
        contentView.backgroundColor = .white
        
        contentView.addSubviews([placeNameLabel,
                                 addressLabel,
                                 distanceLabel])
        
        placeNameLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(5)
        }
        
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(placeNameLabel.snp.bottom).offset(8)
            $0.leading.bottom.equalToSuperview().inset(5)
        }
        
        distanceLabel.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview().inset(5)
            $0.leading.equalTo(addressLabel.snp.trailing).offset(5)
            $0.width.equalTo(70)
        }
    }
}
