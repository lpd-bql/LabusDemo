//
//  FZEmptyDataPlaceholderView.swift
//  ElmApp
//
//  Created by lpd on 2025/1/6.
//  Copyright © 2025 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//

class FZEmptyDataPlaceholderView: UIView{
    
    lazy var emptyImageView: UIImageView = {
        let imgv = UIImageView()
        imgv.contentMode = .scaleAspectFit
        return imgv
    }()
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.eboExtBaseStyle(font: 16.fontEBO(.bold), textColor: .fzUIKit.primaryText, textAlignment: .center)
        view.numberOfLines = 0
        return view
    }()
    
    lazy var detailLabel: UILabel = {
        let view = UILabel()
        view.eboExtBaseStyle(font: 14.fontEBO(.regular), textColor: .fzUIKit.secondaryText, textAlignment: .center)
        view.numberOfLines = 0
        return view
    }()
    
//    lazy var btn: UIButton = {
//        let view = UILabel()   // 刷新按钮  todo...
//        return view
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .fzUIKit.primaryBackground
       
        addSubview(emptyImageView)
        addSubview(titleLabel)
        addSubview(detailLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().dividedBy(0.8)
        }
        detailLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        emptyImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
//            make.width.equalTo(200.adapt)
//            make.height.equalTo(150.adapt)
            make.bottom.equalTo(titleLabel.snp.top).offset(-8)
        }
        
    }
  
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func configure(image: UIImage?, title: String, subtitle: String) {
        emptyImageView.image = image
        titleLabel.text = title
        detailLabel.text = subtitle
    }
}
 

// 空数据占位提示
extension UIView{
    private struct AssociatedKeys {
        static var emptyStateView = "FZEmptyDataPlaceholderView"
    }
    
    private var emptyStateView: FZEmptyDataPlaceholderView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.emptyStateView) as? FZEmptyDataPlaceholderView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.emptyStateView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func showEmptyState(image: UIImage?, title: String, subtitle: String) {
        DispatchQueue.main.async {
            if self.emptyStateView == nil {
                let emptyView = FZEmptyDataPlaceholderView(frame: self.bounds)
                emptyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.addSubview(emptyView)
                self.emptyStateView = emptyView
            }
            self.emptyStateView?.configure(image: image, title: title, subtitle: subtitle)
        }
        
    }
    
    func hideEmptyState() {
        guard let _ = emptyStateView else{ return }
        
        DispatchQueue.main.async {
            self.emptyStateView?.removeFromSuperview()
            self.emptyStateView = nil
        }
    }
    
}
