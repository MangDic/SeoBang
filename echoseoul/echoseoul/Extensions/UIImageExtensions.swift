//
//  UIImageExtensions.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/18.
//
import UIKit

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let newSize = widthRatio < heightRatio ? CGSize(width: size.width * widthRatio, height: size.height * widthRatio) : CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
