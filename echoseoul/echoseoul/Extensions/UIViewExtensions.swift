//
//  UIViewExtensions.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/17.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }
}
