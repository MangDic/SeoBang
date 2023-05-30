//
//  PrivacyDescriptionViewController.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/30.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class PrivacyDescriptionViewController: UIViewController {
    var disposeBag = DisposeBag()
    
    lazy var contentView = UIView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .white
    }
    
    lazy var titleLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.text = "서울 방방곡곡을 사용하실 때\n다음과 같은 권한이 필요합니다."
        $0.textAlignment = .center
        $0.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 18)
    }
    
    lazy var dividerView1 = UIView().then {
        $0.backgroundColor = .lightGray
    }
    
    lazy var essentialLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.text = "필수적 권한"
        $0.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 18)
    }
    
    lazy var healthImageView = UIImageView().then {
        $0.image = UIImage(named: "health")
    }
    
    lazy var healthLabelStack = UIStackView().then {
        $0.spacing = 5
        $0.axis = .vertical
    }
    
    lazy var healthKitDescriptionLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.text = "건강앱 접근 및 통합 권한"
        $0.textColor = .darkGray
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 14)
    }
    
    lazy var healthKitDetailLabel = UILabel().then {
        $0.numberOfLines = 4
        $0.text = "건강앱과 통합하여 걸음수, 이동거리, 소모 칼로리 데이터를 사용자에게 제공하고, 랭크 시스템에 사용됩니다."
        $0.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        $0.font = UIFont(name: "Cafe24-Ohsquareair", size: 12)
    }
    
    lazy var locationImageView = UIImageView().then {
        $0.image = UIImage(named: "navigation")
    }
    
    lazy var locationLabelStack = UIStackView().then {
        $0.spacing = 5
        $0.axis = .vertical
    }
    
    lazy var locationDescriptionLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.text = "사용자 위치 사용 권한"
        $0.textColor = .darkGray
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 14)
    }
    
    lazy var locationDetailLabel = UILabel().then {
        $0.numberOfLines = 4
        $0.text = "사용자의 현재 위치에서 가까운 문화시설 정보를 제공하는데 사용됩니다."
        $0.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        $0.font = UIFont(name: "Cafe24-Ohsquareair", size: 12)
    }
    
    lazy var notiLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.text = "필수적 권한을 동의하지 않으면 해당 앱 사용에 제한이 있습니다."
        $0.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        $0.font = UIFont(name: "Cafe24-Ohsquareair", size: 12)
    }
    
    lazy var dividerView2 = UIView().then {
        $0.backgroundColor = .lightGray
    }
    
    lazy var confirmButton = UIButton().then {
        $0.titleLabel?.font = UIFont(name: "Cafe24Ohsquare", size: 12)
        $0.layer.cornerRadius = 4
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("확인", for: .normal)
        $0.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        $0.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    private func setupLayout() {
        view.backgroundColor = .black
        
        view.addSubview(contentView)
        
        contentView.addSubviews([titleLabel,
                                 dividerView1,
                                 essentialLabel,
                                 healthImageView,
                                 healthLabelStack,
                                 locationImageView,
                                 locationLabelStack,
                                 notiLabel,
                                 dividerView2,
                                 confirmButton])
        
        healthLabelStack.addArrangedSubview(healthKitDescriptionLabel)
        healthLabelStack.addArrangedSubview(healthKitDetailLabel)
        
        locationLabelStack.addArrangedSubview(locationDescriptionLabel)
        locationLabelStack.addArrangedSubview(locationDetailLabel)
        
        contentView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.center.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview().inset(20)
        }
        
        dividerView1.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        essentialLabel.snp.makeConstraints {
            $0.top.equalTo(dividerView1.snp.bottom).offset(25)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        healthImageView.snp.makeConstraints {
            $0.size.equalTo(60)
            $0.centerY.equalTo(healthLabelStack)
            $0.leading.equalToSuperview().inset(20)
        }
        
        healthLabelStack.snp.makeConstraints {
            $0.top.equalTo(essentialLabel.snp.bottom).offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.leading.equalTo(healthImageView.snp.trailing).offset(10)
        }
        
        locationImageView.snp.makeConstraints {
            $0.size.equalTo(60)
            $0.centerY.equalTo(locationLabelStack)
            $0.leading.equalToSuperview().inset(20)
        }
        
        locationLabelStack.snp.makeConstraints {
            $0.top.equalTo(healthLabelStack.snp.bottom).offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.leading.equalTo(healthImageView.snp.trailing).offset(10)
        }
        
        notiLabel.snp.makeConstraints {
            $0.top.equalTo(locationLabelStack.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        dividerView2.snp.makeConstraints {
            $0.top.equalTo(notiLabel.snp.bottom).offset(20)
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        confirmButton.snp.makeConstraints {
            $0.top.equalTo(dividerView2.snp.bottom).offset(20)
            $0.height.equalTo(30)
            $0.leading.bottom.trailing.equalToSuperview().inset(20)
        }
    }
}
