//
//  UIImageExtensions.swift
//  BookSummaryPlayerTestTask
//
//  Created by Yulian on 23.01.2024.
//

import UIKit

public extension UIImage {
    func withColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        guard let ctx = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return self }
        
        color.setFill()
        
        ctx.translateBy(x: 0, y: size.height)
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.clip(to: CGRect(x: 0, y: 0, width: size.width, height: size.height), mask: cgImage)
        ctx.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        guard let colored = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        
        UIGraphicsEndImageContext()
        
        return colored
    }
}
