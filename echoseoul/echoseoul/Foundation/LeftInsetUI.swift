//
//  LeftInsetUI.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/24.
//

import UIKit

class InsetTextField: UITextField {
    var textPadding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
}

class InsetButton: UIButton {
    var titlePadding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return contentRect.inset(by: titlePadding)
    }
}
