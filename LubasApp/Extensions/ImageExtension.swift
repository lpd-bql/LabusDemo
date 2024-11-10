//
//  ssssss.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/15.
//

import UIKit

extension UIImage{
    
    // 使用 CoreGraphics 生成圆角图片
    func makeRoundedImage(from image: UIImage, r: CGFloat) -> UIImage? {
        
        let rect = CGRect(origin: .zero, size: image.size)
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        UIBezierPath(roundedRect: rect, cornerRadius: r).addClip()
        image.draw(in: rect)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage
    }
    
    // 大图
    func largheIcon(_ name: String) -> UIImage {
        // 用于设置 SF Symbols 的类，可以调整 SF Symbols 的外观，包括比例、权重、点大小等。
        let cfg = UIImage.SymbolConfiguration(scale: .large)
        return UIImage(systemName: name, withConfiguration: cfg)!
    }

}
