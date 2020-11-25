//
//  UIImage+Resize.swift
//  MyLocation
//
//  Created by Denis Suspicin on 25.11.2020.
//

import UIKit

extension UIImage {
    //уменьшает картинку до нужного размера
    func resized(withBounds bounds: CGSize) -> UIImage {
        let horizontalRation = bounds.width / size.width
        let verticalRation = bounds.height / size.height
        let ration = min(horizontalRation, verticalRation)
        let newSize = CGSize(width: size.width * ration, height: size.height * ration)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
