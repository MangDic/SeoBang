//
//  PlaceDetailView.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/19.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class PlaceDetailView: UIView {
    var disposeBag = DisposeBag()
    let placeRelay = PublishRelay<Place>()
    
    var currentUrl = ""
    let infoTextViewMaxHeight: CGFloat = 200
    
    let dismissRelay = PublishRelay<Void>()
    
    lazy var blockView = UIButton().then {
        $0.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.17)
        $0.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.dismissRelay.accept(())
        }).disposed(by: disposeBag)
    }
    
    lazy var contentView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    lazy var placeNameLabel = UILabel().then {
        $0.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 18)
    }
    
    lazy var addressLabel = UILabel().then {
        $0.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        $0.font = UIFont(name: "Cafe24Ohsquare", size: 16)
    }
    
    lazy var infoLabel = UITextView().then {
        $0.isEditable = false
        $0.layer.borderWidth = 1
        $0.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .white
        $0.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        $0.font = UIFont(name: "Cafe24-Ohsquareair", size: 14)
    }
    
    lazy var urlButton = UIButton().then {
        $0.contentHorizontalAlignment = .left
        $0.setTitleColor(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), for: .normal)
        $0.titleLabel?.font = UIFont(name: "Cafe24Ohsquare", size: 14)
        $0.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if self.currentUrl == "" { return }
            self.openUrl()
        }).disposed(by: disposeBag)
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
        addSubviews([blockView, contentView])
        contentView.addSubviews([placeNameLabel,
                                 addressLabel,
                                 infoLabel,
                                 urlButton])
        
        blockView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width * 0.8)
            $0.center.equalToSuperview()
        }
        
        placeNameLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview().inset(20)
        }
        
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(placeNameLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(100)
        }
        
        urlButton.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(10)
            $0.leading.bottom.trailing.equalToSuperview().inset(20)
        }
        
        layoutIfNeeded()
    }
    
    private func bind() {
        placeRelay.subscribe(onNext: { [weak self] place in
            guard let `self` = self else { return }
            self.placeNameLabel.text = self.stripHtmlTags(from: place.facName)
            self.addressLabel.text = self.stripHtmlTags(from: place.addr)
            self.infoLabel.text = self.stripHtmlTags(from: place.facDesc)
            self.urlButton.setTitle(self.stripHtmlTags(from: place.homepage), for: .normal)
            self.currentUrl = self.stripHtmlTags(from: place.homepage)
            self.setupUrlUnderline()
            self.updateInfoLabelHeight()
        }).disposed(by: disposeBag)
    }
    
    private func stripHtmlTags(from string: String) -> String {
        let convertedString = string
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "&nbsp;", with: "\n")
        
        let pattern = "&[^;]*;"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: convertedString.utf16.count)
            let modifiedString = regex.stringByReplacingMatches(in: convertedString, options: [], range: range, withTemplate: "")
            
            return modifiedString
        }
        catch {
            return ""
        }
    }
    
    private func updateInfoLabelHeight() {
        let size = CGSize(width: infoLabel.frame.width, height: .infinity)
        let estimatedSize = infoLabel.sizeThatFits(size)
        
        let height = estimatedSize.height > infoTextViewMaxHeight ?  infoTextViewMaxHeight : estimatedSize.height
        
        infoLabel.snp.updateConstraints {
            $0.height.equalTo(height)
        }
    }
    
    private func setupUrlUnderline() {
        let attributedTitle = NSAttributedString(string: currentUrl, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])

        urlButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    private func openUrl() {
        if currentUrl.hasPrefix("http://") || currentUrl.hasPrefix("https://") {
            
            // Percent-encoding 처리
            if let encodedString = currentUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: encodedString) {
                
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else {
                print("Invalid URL.")
            }
        } else {
            print("URL must start with 'http://' or 'https://'.")
        }
    }
}
