//
//  ssssss.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/15.
//


import UIKit

class PopupView: UIView {
    var contentViewWidth: CGFloat
    var contentViewHeight: CGFloat
    
    // 弹出窗口视图；
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    // 背景遮罩视图
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.alpha = 0 // 初始隐藏
        return view
    }()
    
    init?(width: CGFloat, height: CGFloat) {
        guard width > 0 else {
            return nil  // 构造失败
        }
        
        self.contentViewWidth = width
        self.contentViewHeight = height
        super.init(frame: CGRect.zero)
        
        self.setupUI()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 子类自定义 内容
    func setupUI(){
        
    }
    
    func showPopup(on view: UIView) {
        // 添加背景视图
        view.addSubview(backgroundView)
        backgroundView.frame = view.bounds
        
        // 添加背景点击手势，只关闭背景而不影响弹窗
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        backgroundView.addGestureRecognizer(tapGesture)

        // 添加弹出视图
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.widthAnchor.constraint(equalToConstant: 250),
            contentView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        // 设置初始缩放和透明度为0，准备动画
        contentView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        contentView.alpha = 0
        
        // 动画显示弹出视图和背景
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 1
            self.contentView.alpha = 1
            self.contentView.transform = CGAffineTransform.identity
        }
    }
    
    
    @objc func dismissPopup() {
        // 动画隐藏弹出视图和背景
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView.alpha = 0
            self.backgroundView.alpha = 0
            self.contentView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            // 动画结束后移除视图
            self.contentView.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
        }
    }
}
