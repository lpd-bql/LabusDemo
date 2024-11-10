//
//  xxxxxx.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/15.
//

import UIKit

extension UIView{
    
    /// 设圆角（传统方式）
    /// - Parameters:
    ///   - r: 圆角半径
    ///   - mk: 是否切割
    func setCornerRadius(r: CGFloat, msk: Bool){
        self.layer.cornerRadius = r
        self.layer.masksToBounds = msk
    }
    
    /// 设圆角（通过UIBezierPath）（ 需要bounds）
    /// - Parameter r: 圆角半径
    func setCornerRadiusByBezier(r: CGFloat){
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], cornerRadii: CGSize(width: r, height: r))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    /// 添加阴影（ 需要bounds）
    /// - Parameter r: 圆角 r
    func setShadow(r: CGFloat){
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = r
        self.layer.shadowOffset = CGSize(width: 0, height: 2)

        // 提供一个自定义的 shadowPath 避免离屏渲染
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
    
    
    /// 删除所有的子视图
    func removeAllSubViews() {
        for view: UIView in self.subviews{
            view.removeFromSuperview()
        }
    }
    
    /// 加载XIB文件
    public class func initWithXibName(_ xib: String) -> Any? {
        guard let nibs:Array = Bundle.main.loadNibNamed(xib, owner: nil, options: nil) else{
            return nil
        }
        return nibs.first
    }
    
    /// 把UIView 渲染成 UIImage
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { (rendererContext) in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
}
