//
//  Untitled.swift
//  ElmApp
//
//  Created by lpd on 2025/2/14.
//  Copyright © 2025 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//

import SnapKit
import UIKit

enum FZCommonTableCellType {
    case titleWithArrow          // 标题 + 右侧箭头
    case titleWithSwitch         // 标题 + 右侧开关
    case titleWithTick           // 标题 + 右侧勾选
    case titleValueWithArrow     // 标题 + 值 右侧箭头
    case titleSubtitleWithArrow  // 标题 副标题 + 右侧箭头
    case titleSubtitleWithSwitch // 标题 副标题 + 右侧开关
    case titleSubtitleWithTick   // 标题 副标题 + 右侧勾选
    case titleSubtitleValueWithArrow  // 标题 副标题 + 值 右侧箭头
     

}

protocol FZCommonTableCellDelegate: AnyObject {
    func cellSwitchDidToggled(isOn: Bool, indexPath: IndexPath)
    
    func cellTickBtnDidToggled(isSelected: Bool, indexPath: IndexPath)

}

class FZCommonTableCell: UITableViewCell{
    weak var delegate: FZCommonTableCellDelegate?
    
    var titleLabelTopConstraint: Constraint?  // 用于 动态布局
    lazy var titleLabel: UILabel = {
        let lb = UILabel()
//        lb.eboExtBaseStyle(font: 16.fontEBO(.bold), textColor: .fzUIKit.primaryText, textAlignment: .left)
        lb.numberOfLines = 0
        lb.setContentHuggingPriority(.defaultHigh, for: .horizontal) // 250（默认）
        lb.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal) // 750（默认）
        return lb
    }()
     
    private var subTitleLabelTrailingConstraint: Constraint?  // 用于 动态布局，自动计算行高
    lazy var subTitleLabel: UILabel = {
        let lb = UILabel()
//        lb.eboExtBaseStyle(font: 14.fontEBO(.regular), textColor: .fzUIKit.secondaryText, textAlignment: .left)
        lb.numberOfLines = 0
        return lb
    }()
    
    lazy var valueLabel: UILabel = {
        let lb = UILabel()
//        lb.eboExtBaseStyle(font: 14.fontEBO(.regular), textColor: .fzUIKit.secondaryText, textAlignment: .right)
        lb.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lb.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return lb
    }()
     
    lazy var tickBtn: UIButton = {
        let b = UIButton()
        b.addTarget(self, action: #selector(tickAction), for: .touchUpInside)
//        b.setImage(.fz.imgName(light: "", dark: "btnTikO"), for: .normal)
//        b.setImage(.fz.imgName(light: "", dark: "btnTiked"), for: .selected)
        return b
    }()
    
    lazy var arrowView: UIImageView = {
        let view = UIImageView()
//        view.image = .fz.imgName(light: "", dark: "MediaArrowIcon")
        return view
    }()
     
    lazy var switchBtn: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(switchAction), for: .touchUpInside)
//        view.setImage(.fz.imgName(light: "", dark: ImageSet.switchButtonOffIcon), for: .normal)
//        view.setImage(.fz.imgName(light: ImageSet.switchButtonOnIcon, dark: "SwitchButtonOnIcon2"), for: .selected) 
        return view
    }()
    
    lazy var bgRadiusView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hex: 0x585B5C)  
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    @objc func switchAction(){
        switchBtn.isSelected = !switchBtn.isSelected
        
        guard let tableView = superTableView() else { return }
        guard let indexPath: IndexPath = tableView.indexPath(for: self) else { return }
        
        delegate?.cellSwitchDidToggled(isOn: switchBtn.isSelected, indexPath: indexPath)
    }
    
    @objc func tickAction(){
        tickBtn.isSelected = !tickBtn.isSelected
        
        guard let tableView = superTableView() else { return }
        guard let indexPath: IndexPath = tableView.indexPath(for: self) else { return }
        
        delegate?.cellTickBtnDidToggled(isSelected: tickBtn.isSelected, indexPath: indexPath)
    }
}
 

// MARK: 配置业务数据
extension FZCommonTableCell{
    
    func config(with model: FZCommonTableCellItem){
        titleLabel.text = model.title
        subTitleLabel.text = model.subTitle
        valueLabel.text = model.valueStr
        switchBtn.isSelected = model.isOn ?? false
        tickBtn.isSelected = model.isTicked ?? false
        
        config(type: model.cellType)  // 配置UI样式
         
    }
}

// MARK: 配置UI样式
extension FZCommonTableCell{
    
    // 更新 圆角样式
    public func updateRadius(_ radius: CGFloat, currentSectionCellCount: Int, correntRow: Int){
        bottomLine.isHidden = true
        
        // section 只有一个 cell 的情况
        if currentSectionCellCount == 1 {
            // 四个角都加圆角
            bgRadiusView.layer.cornerRadius = radius
            bgRadiusView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            return
        }
        
        if correntRow == 0 {
            // section的第一个 cell，顶部圆角
            bgRadiusView.layer.cornerRadius = radius
            bgRadiusView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            bottomLine.isHidden = false

        } else if correntRow == currentSectionCellCount - 1 {
            // section的最后一个 cell，底部圆角
            bgRadiusView.layer.cornerRadius = radius
            bgRadiusView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            // section中间的 cell，无圆角
            bgRadiusView.layer.cornerRadius = 0
            bgRadiusView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            bottomLine.isHidden = false
        }
    }
    
    
}

extension FZCommonTableCell{
    
    private func config(type: FZCommonTableCellType){
        
        [titleLabel, arrowView, subTitleLabel, valueLabel, switchBtn, tickBtn].forEach {
            $0.isHidden = true
        }
        
        titleLabel.isHidden = false  // 总是显示

        switch type {
            case .titleWithArrow:
                arrowView.isHidden = false
                
            case .titleWithSwitch:
                switchBtn.isHidden = false
                
            case .titleWithTick:
                tickBtn.isHidden = false
                  
            case .titleValueWithArrow:
                arrowView.isHidden = false
                valueLabel.isHidden = false

            case .titleSubtitleWithArrow:
                arrowView.isHidden = false
                subTitleLabel.isHidden = false

            case .titleSubtitleWithSwitch:
                subTitleLabel.isHidden = false
                switchBtn.isHidden = false
                
            case .titleSubtitleWithTick:
                tickBtn.isHidden = false
                subTitleLabel.isHidden = false
                
            case .titleSubtitleValueWithArrow:
                subTitleLabel.isHidden = false
                arrowView.isHidden = false
                valueLabel.isHidden = false
             
        }
        
        dymaticLayoutSubTitleLabel()
    }
    
    private func dymaticLayoutSubTitleLabel(){
        if subTitleLabel.isHidden {
            // subTitleLabel 隐藏时，不需要 此约束
            subTitleLabelTrailingConstraint?.deactivate()
            subTitleLabelTrailingConstraint = nil
        }else{
            // 需要
            guard let _ = subTitleLabelTrailingConstraint else {
                // 如果未添加约束，则添加
                subTitleLabel.snp.makeConstraints { make in
                    subTitleLabelTrailingConstraint = make.bottom.equalToSuperview().offset(-16).constraint
                }
                return
            }
        }
    }
    
    private func setupUI(){
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .white
        
        contentView.addSubview(bgRadiusView)
        
        bgRadiusView.addSubview(titleLabel)
        bgRadiusView.addSubview(subTitleLabel)
        bgRadiusView.addSubview(valueLabel)
        bgRadiusView.addSubview(arrowView)
        bgRadiusView.addSubview(switchBtn)
        bgRadiusView.addSubview(tickBtn)
        bgRadiusView.addSubview(bottomLine)
        
        bgRadiusView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
        
        bottomLine.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            titleLabelTopConstraint = make.top.equalToSuperview().offset(16).constraint
            make.leading.equalToSuperview().offset(16)
//            make.trailing.equalTo(bgRadiusView.snp.centerX)   //?
        }
          
        subTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        arrowView.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(16)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(12)
            make.trailing.equalTo(arrowView.snp.leading).offset(-12)
        }
        
        switchBtn.snp.makeConstraints { make in
            make.centerY.trailing.equalTo(arrowView)
            make.width.equalTo(37)
            make.height.equalTo(22)
        }
        
        tickBtn.snp.makeConstraints { make in
            make.centerY.trailing.equalTo(arrowView)
            make.width.height.equalTo(20)
        }
    }
}
 

extension UITableViewCell {
    //get super tableView
    func superTableView() -> UITableView? {
        for view in sequence(first: self.superview, next: { $0?.superview }) {
            if let tableView = view as? UITableView {
                return tableView
            }
        }
        return nil
    }
}
