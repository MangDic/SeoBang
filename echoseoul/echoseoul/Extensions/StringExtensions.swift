//
//  StringExtensions.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/17.
//

import Foundation

extension String {
    func convertData() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyyMMddHHmm"

        guard let date = inputFormatter.date(from: self) else {
            fatalError("Invalid input format")
        }

        // Date 객체를 원하는 형식의 문자열로 변환
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ko_KR") // 한국어를 위한 로케일 설정
        outputFormatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"

        let output = outputFormatter.string(from: date)
        return output
    }
}

