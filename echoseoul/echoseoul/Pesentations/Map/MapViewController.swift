//
//  MapViewController.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/18.
//
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import NMapsMap

class MapViewController: UIViewController {
    var disposeBag = DisposeBag()
    
    var locationManager: CLLocationManager!
    let placeService = PlaceService.shared
    
    var isMapInitialized = false
    var naverMapView: NMFNaverMapView!
    var markers: [String: NMFMarker] = [:]
    let isShowDetailView = PublishRelay<Bool>()
    
    lazy var stepsLabel = UILabel().then {
        $0.alpha = 0.8
        $0.clipsToBounds = true
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 11)
        $0.textAlignment = .center
        $0.text = "- 걸음"
        $0.layer.cornerRadius = 6
        $0.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        $0.textColor = #colorLiteral(red: 0.9693942666, green: 0.9693942666, blue: 0.9693942666, alpha: 1)
    }
    
    lazy var distanceLabel = UILabel().then {
        $0.alpha = 0.8
        $0.clipsToBounds = true
        $0.numberOfLines = 2
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 11)
        $0.textAlignment = .center
        $0.text = "오늘의 이동거리\n0m"
        $0.layer.cornerRadius = 6
        $0.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        $0.textColor = #colorLiteral(red: 0.9693942666, green: 0.9693942666, blue: 0.9693942666, alpha: 1)
    }
    
    lazy var clearLabel = UILabel().then {
        $0.alpha = 0.8
        $0.clipsToBounds = true
        $0.numberOfLines = 2
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 11)
        $0.textAlignment = .center
        $0.text = "클리어 0개"
        $0.layer.cornerRadius = 6
        $0.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        $0.textColor = #colorLiteral(red: 0.9693942666, green: 0.9693942666, blue: 0.9693942666, alpha: 1)
    }
    
    lazy var tableView = UITableView().then {
        $0.rowHeight = UITableView.automaticDimension
        $0.register(PlaceCell.self, forCellReuseIdentifier: PlaceCell.id)
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
    }
    
    lazy var completedLabel = UILabel().then {
        $0.alpha = 0
        $0.isHidden = true
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.textColor = .white
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 14)
        $0.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8022566031)
    }
    
    lazy var listControlButton = UIButton().then {
        $0.tintColor = .white
        $0.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        $0.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        $0.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.setupTableViewVisible()
        }).disposed(by: disposeBag)
    }
    
    lazy var placeDetailView = PlaceDetailView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        setupMapView()
        setupLayout()
        bind()
    }
    
    private func setupMapView() {
        naverMapView = NMFNaverMapView(frame: view.frame)
        naverMapView.showLocationButton = true
        naverMapView.mapView.zoomLevel = 14
        naverMapView.mapView.positionMode = .compass
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied, .restricted, .notDetermined:
            break
        @unknown default:
            fatalError("A new case was added to CLAuthorizationStatus")
        }
    }
    
    private func setupLayout() {
        view.addSubviews([naverMapView,
                          stepsLabel,
                          distanceLabel,
                          clearLabel,
                          tableView,
                          completedLabel,
                          listControlButton])
        
        naverMapView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.6)
        }
        
        clearLabel.snp.makeConstraints {
            $0.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.size.equalTo(CGSize(width: 90, height: 30))
        }
        
        stepsLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.top.equalTo(clearLabel.snp.bottom).offset(10)
            $0.size.equalTo(CGSize(width: 90, height: 30))
        }
        
        distanceLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.top.equalTo(stepsLabel.snp.bottom).offset(10)
            $0.size.equalTo(CGSize(width: 90, height: 45))
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(naverMapView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        completedLabel.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.height.equalTo(60)
        }
        
        listControlButton.snp.makeConstraints {
            $0.trailing.equalTo(naverMapView).inset(10)
            $0.bottom.equalTo(naverMapView).inset(40)
            $0.size.equalTo(40)
        }
        
        listControlButton.layer.cornerRadius = 20
    }
    
    private func bind() {
        tableView.delegate = self
        
        placeService.placeRelay
            .subscribe(onNext: { [weak self] data in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    for (i, item) in data.enumerated() {
                        let marker = NMFMarker()
                        let x = Double(item.xCoord) ?? 0.0
                        let y = Double(item.yCoord) ?? 0.0
                        
                        marker.captionRequestedWidth = 60
                        marker.captionText = item.facName
                        marker.position = NMGLatLng(lat: x, lng: y)
                        marker.tag = UInt(i)
                        
                        let name = item.isCompleted ? "check" : "warning"
                        let image = UIImage(named: name)!.resizeImage(targetSize: CGSize(width: 25, height: 25))
                        marker.iconImage = NMFOverlayImage(image: image)
                        
                        let handler = { [weak self] (overlay: NMFOverlay) -> Bool in
                            if let marker = overlay as? NMFMarker {
                                if let place = self?.placeService.placeRelay.value[Int(marker.tag)] {
                                    self?.placeDetailView.placeRelay.accept(place)
                                    self?.placeDetailView.infoLabel.contentOffset = CGPoint(x: 0, y: 0)
                                    if !self!.tableView.isHidden {
                                        self?.setupTableViewVisible()
                                    }
                                    self?.isShowDetailView.accept(true)
                                }
                            }
                            return true
                        }
                        
                        marker.touchHandler = handler
                        self.markers[item.facName] = marker
                        marker.mapView = self.naverMapView.mapView
                    }
                }
            }).disposed(by: disposeBag)
        
        placeService.completedRelay
            .subscribe(onNext: { [weak self] place in
                guard let `self` = self else { return }
                self.showCompletedLabel(placeName: place)
                UserInfoService.shared.clearCount += 1
                self.completedLabel.text = "클리어 \(UserInfoService.shared.clearCount)"
            }).disposed(by: disposeBag)
        
        placeService.placeRelay
            .skip(1)
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: PlaceCell.id)) { row, item, cell in
                guard let cell = cell as? PlaceCell else { return }
                cell.selectionStyle = .none
                cell.configure(item: item)
            }.disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(Place.self)
            .subscribe(onNext: { [weak self] data in
                guard let `self` = self else { return }
                let x = Double(data.xCoord) ?? 0
                let y = Double(data.yCoord) ?? 0
                self.moveCamera(lat: x, lng: y)
            }).disposed(by: disposeBag)
        
        HealthService.shared.stepsRelay.subscribe(onNext: { [weak self] steps in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.stepsLabel.text = "\(steps) 걸음"
            }
        }).disposed(by: disposeBag)
        
        HealthService.shared.distanceRelay.subscribe(onNext: { [weak self] distance in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.distanceLabel.text = "오늘의 이동거리\n\(Int(distance))m"
            }
        }).disposed(by: disposeBag)
        
        isShowDetailView
            .subscribe(onNext: { [weak self] isShow in
                guard let `self` = self else { return }
                if isShow {
                    self.showDetailView()
                }
                else {
                    self.hideDetailView()
                }
            }).disposed(by: disposeBag)
        
        placeDetailView.dismissRelay
            .map { _ in false }
            .bind(to: isShowDetailView)
            .disposed(by: disposeBag)
    }
    
    private func moveCamera(lat: Double, lng: Double, place: String? = nil) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
        
        naverMapView.mapView.moveCamera(cameraUpdate)
    }
    
    private func setupTableViewVisible() {
        tableView.isHidden = !tableView.isHidden
        if tableView.isHidden {
            naverMapView.snp.remakeConstraints {
                $0.leading.top.trailing.equalToSuperview()
                $0.bottom.equalTo(view.safeAreaLayoutGuide)
            }
        }
        else {
            naverMapView.snp.remakeConstraints {
                $0.leading.top.trailing.equalToSuperview()
                $0.height.equalToSuperview().multipliedBy(0.6)
            }
            tableView.snp.remakeConstraints {
                $0.top.equalTo(naverMapView.snp.bottom)
                $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            }
        }
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showCompletedLabel(placeName: String) {
        DispatchQueue.main.async {
            self.completedLabel.text = "축하합니다!\n\(placeName)에 도착하였습니다."
            UIView.animate(withDuration: 0.8, delay: 0, animations: {
                self.completedLabel.isHidden = false
                self.completedLabel.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 0.8, delay: 0, animations: {
                    self.completedLabel.alpha = 0
                }, completion: { _ in
                    self.completedLabel.isHidden = true
                })
            })
        }
    }
    
    private func showDetailView() {
        view.addSubview(placeDetailView)
        
        placeDetailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func hideDetailView() {
        placeDetailView.removeFromSuperview()
    }
    
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        self.isShowDetailView.accept(false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.isShowDetailView.accept(false)
    }
}

extension MapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        let containerView = UIView().then {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.backgroundColor = .white
        }
        
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(5)
        }
        
        return view
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            naverMapView.mapView.locationOverlay.location = NMGLatLng(lat: lat, lng: lng)
            placeService.updateCurrentRelay.accept((lat, lng))
            if !isMapInitialized {
                isMapInitialized = true
                moveCamera(lat: lat, lng: lng)
            }
        }
    }
}

