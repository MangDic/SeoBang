//
//  SetupViewController.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class SetupViewController: UIViewController {
    var disposeBag = DisposeBag()
    
    let nickNameRelay = BehaviorRelay<String>(value: "")
    var selectedRegion = ""
    
    lazy var contentView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = #colorLiteral(red: 0.8960018754, green: 0.9072814584, blue: 0.9070830941, alpha: 1)
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 8
    }
    
    lazy var setupDescriptionLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.text = "간단하게 정보를 등록해 주세요:)"
        $0.textAlignment = .center
        $0.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 16)
    }
    
    lazy var nickNameField = InsetTextField().then {
        $0.layer.cornerRadius = 4
        $0.layer.borderColor = #colorLiteral(red: 0.8960018754, green: 0.9072814584, blue: 0.9070830941, alpha: 1)
        $0.layer.borderWidth = 2
        $0.backgroundColor = .white
        $0.textColor = .black
        $0.font = UIFont(name: "Cafe24-Ohsquareair", size: 14)
        $0.borderStyle = .none
        let placeholder = "닉네임을 입력하세요"
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
            .font: UIFont(name: "Cafe24-Ohsquareair", size: 14)!
        ]
        $0.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)
    }
    
    lazy var regionButton = InsetButton().then {
        $0.layer.cornerRadius = 4
        $0.layer.borderColor = #colorLiteral(red: 0.8960018754, green: 0.9072814584, blue: 0.9070830941, alpha: 1)
        $0.layer.borderWidth = 2
        $0.backgroundColor = .clear
        $0.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .normal)
        $0.titleLabel?.font = UIFont(name: "Cafe24-Ohsquareair", size: 14)
        $0.contentHorizontalAlignment = .left
        $0.setTitle("위치를 선택하세요", for: .normal)
        $0.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.regionSelectView.isHidden = false
            self.view.endEditing(true)
        }).disposed(by: disposeBag)
    }
    
    lazy var regionSelectView = RegionSelectView().then {
        $0.clipsToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        $0.layer.cornerRadius = 8
        $0.isHidden = true
    }
    
    lazy var saveButton = UIButton().then {
        $0.titleLabel?.font = UIFont(name: "Cafe24Ohsquare", size: 14)
        $0.setTitle("저장", for: .normal)
        $0.layer.cornerRadius = 4
        $0.backgroundColor = #colorLiteral(red: 0.6969236732, green: 0.7056968808, blue: 0.7055425644, alpha: 1)
        $0.isEnabled = false
        $0.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.saveData()
        }).disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bind()
    }
    
    private func setupLayout() {
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        view.addSubviews([contentView, regionSelectView])
        
        contentView.addSubviews([setupDescriptionLabel,
                                 nickNameField,
                                 regionButton,
                                 saveButton])
        
        contentView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.center.equalToSuperview()
        }
        
        setupDescriptionLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview().inset(20)
        }
        
        nickNameField.snp.makeConstraints {
            $0.top.equalTo(setupDescriptionLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        
        regionButton.snp.makeConstraints {
            $0.top.equalTo(nickNameField.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        
        regionSelectView.snp.makeConstraints {
            $0.top.equalTo(regionButton.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(160)
            $0.width.equalTo(regionButton)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(regionButton.snp.bottom).offset(20)
            $0.leading.bottom.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func bind() {
        regionSelectView.selectedRelay
            .subscribe(onNext: { [weak self] region in
                guard let `self` = self else { return }
                self.regionSelectView.isHidden = true
                self.selectedRegion = region
                self.regionButton.setTitle(region, for: .normal)
                self.regionButton.setTitleColor(.black, for: .normal)
            }).disposed(by: disposeBag)
        
        nickNameField.rx.text.subscribe(onNext: { [weak self] text in
            guard let `self` = self else { return }
            self.nickNameRelay.accept(text ?? "")
        }).disposed(by: disposeBag)
        
        Observable
            .combineLatest(nickNameRelay, regionSelectView.selectedRelay)
            .subscribe(onNext: { [weak self] nickName, region in
                guard let `self` = self else { return }
                
                self.saveButton.backgroundColor = nickName == "" || self.selectedRegion == "" ? #colorLiteral(red: 0.6969236732, green: 0.7056968808, blue: 0.7055425644, alpha: 1) : #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
                self.saveButton.isEnabled = nickName != ""
            }).disposed(by: disposeBag)
    }
    
    private func saveData() {
        let nickName = nickNameRelay.value
        UserInfoService.shared.updateUserInfo(userNickName: nickName,
                                              region: selectedRegion)
        
        RankService.shared.updateMyData(completion: { [weak self] error in
            guard let `self` = self else { return }
            if let error = error {
                print(error)
            }
            else {
                self.navigationController?.popViewController(animated: false)
                self.navigationController?.pushViewController(MainTabBarController(), animated: false)
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
        regionSelectView.isHidden = true
    }
}
