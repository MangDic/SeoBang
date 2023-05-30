//
//  HomeViewControllerController.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/17.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift

class HomeViewControllerController: UIViewController {
    var disposeBag = DisposeBag()
    
    let blockRelay = BehaviorRelay<Bool>(value: true)
    let selectedRelay = BehaviorRelay<Region?>(value: nil)
    
    var regionData = [Region]()
    
    lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    lazy var blockView = UIView().then {
        $0.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.21)
    }
    
    lazy var loadingDescriptionLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.text = "데이터를 불러오고 있습니다.\n잠시만 기다려주세요 :)"
        $0.textAlignment = .center
        $0.textColor = #colorLiteral(red: 0.9693942666, green: 0.9693942666, blue: 0.9693942666, alpha: 1)
        $0.font = UIFont(name: "Cafe24-Ohsquareair", size: 16)
    }
    
    lazy var regionButton = UIButton().then {
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(#colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1), for: .normal)
        $0.titleLabel?.font = UIFont(name: "Cafe24Ohsquare", size: 30)
        $0.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.regionSelectView.isHidden = false
        }).disposed(by: disposeBag)
    }
    
    lazy var dateLabel = UILabel().then {
        $0.textAlignment = .right
        $0.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        $0.font = UIFont(name: "Cafe24-Ohsquareair", size: 12)
    }
    
    lazy var monthDescriptionLabel = UILabel().then {
        $0.text = "\(self.getCurrentMonth())월의 순위"
        $0.textAlignment = .center
        $0.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 18)
    }
    
    lazy var weatherView = WeatherInfoView()
    
    lazy var healthView = HealthDataView()
    
    lazy var rankView = RankView()
    
    lazy var regionSelectView = RegionSelectView().then {
        $0.clipsToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        $0.layer.cornerRadius = 8
        $0.isHidden = true
    }
    
    lazy var updateButton = UIButton().then {
        $0.titleLabel?.font = UIFont(name: "Cafe24-Ohsquareair", size: 12)
        $0.setTitleColor(.darkGray, for: .normal)
        $0.setTitle("정보 업데이트", for: .normal)
        $0.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.blockRelay.accept(true)
                self.updateMyData()
            }).disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bind()
    }
    
    private func updateMyData() {
        RankService.shared.updateMyData(completion: { [weak self] error in
            guard let `self` = self else { return }
            if let error = error {
                print(error)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.rankView.selectRelay.accept(.region)
                    self.rankView.scrollToTop()
                }
            }
        })
    }
    
    private func setupLayout() {
        view.addSubviews([regionButton,
                          weatherView,
                          healthView,
                          dateLabel,
                          monthDescriptionLabel,
                          updateButton,
                          rankView,
                          regionSelectView,
                          blockView])
        
        blockView.addSubviews([activityIndicator,
                               loadingDescriptionLabel])
        
        regionButton.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(25)
        }
        
        weatherView.snp.makeConstraints {
            $0.top.equalTo(regionButton.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(regionButton)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(weatherView.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(regionButton)
        }
        
        healthView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(regionButton)
            $0.height.equalTo(50)
        }
        
        monthDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(healthView.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(regionButton)
        }
        
        updateButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 80, height: 20))
            $0.trailing.equalTo(regionButton)
            $0.centerY.equalTo(monthDescriptionLabel)
        }
        
        rankView.snp.makeConstraints {
            $0.top.equalTo(monthDescriptionLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
        regionSelectView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.height.equalToSuperview().multipliedBy(0.4)
            $0.top.equalTo(regionButton.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
        }
        
        blockView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        loadingDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(activityIndicator.snp.bottom).offset(3)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func bind() {
        Observable
            .combineLatest(AirInfoService.shared.regionDataRelay,
                           RankService.shared.dataRelay)
            .subscribe(onNext: { [weak self] regions, ranks in
                guard let `self` = self else { return }
                if regions.count == 0 || ranks.count == 0 {
                    return
                }
                
                if let data = AirInfoService.shared.findRegionData(target: UserInfoService.shared.region) {
                    self.regionSelectView.isHidden = true
                    self.selectedRelay.accept(data)
                    self.updateUI(data: data)
                }
                
                self.blockRelay.accept(false)
            }).disposed(by: disposeBag)
        
        blockRelay
            .subscribe(onNext: { [weak self] isBlock in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.blockView.isHidden = !isBlock
                    if isBlock {
                        self.activityIndicator.startAnimating()
                    }
                    else {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }).disposed(by: disposeBag)
        
        regionSelectView.selectedRelay
            .subscribe(onNext: { [weak self] city in
                guard let `self` = self else { return }
                if let data = AirInfoService.shared.findRegionData(target: city) {
                    self.regionSelectView.isHidden = true
                    self.selectedRelay.accept(data)
                    self.updateUI(data: data)
                }
            }).disposed(by: disposeBag)
    }
    
    private func updateUI(data: Region?) {
        guard let data = data else { return }
        
        DispatchQueue.main.async {
            self.regionButton.setTitle("서울특별시 " + data.MSRSTE_NM, for: .normal)
            self.weatherView.updateStateLabel(state: data.IDEX_NM)
            self.dateLabel.text = data.MSRDT.convertData() + " 기준"
        }
    }
    
    private func getCurrentMonth() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: date)
        return components.month!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.regionSelectView.isHidden = true
    }
}

