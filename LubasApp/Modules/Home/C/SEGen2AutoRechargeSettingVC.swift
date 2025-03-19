//
//  SEGen2AutoRechargeSettingVC.swift
//  ElmApp
//
//  Created by lpd on 2024/12/11.
//  Copyright © 2024 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//

import Combine

class SEGen2AutoRechargeSettingVC: EBOBaseViewController {
    weak var cardProcessor: SEGen2CardProcessor?
    private var cancellables = Set<AnyCancellable>()

    var settingHour = 0
    var settingMin = 0
    var settingIsOn = false
  
    lazy var items: FZCommonTableItems = {
        let section0 = [
            FZCommonTableCellItem(title: L10n.txtChargeHelpMode, cellType: .titleSubtitleWithTick, actionType: .autoRechargManual, subTitle: L10n.txtSe2TimedRechargeTip1),
            FZCommonTableCellItem(title: L10n.txtChargeRandomMode, cellType: .titleSubtitleWithTick, actionType: .autoRechargAuto, subTitle: L10n.txtSe2TimedRechargeTip2)
        ]
        let section1 = [
            FZCommonTableCellItem(title: L10n.txtTimedRecharge, cellType: .titleWithSwitch, actionType: .autoRechargSwitch),
            FZCommonTableCellItem(title: L10n.txtRechargeTime, cellType: .titleValueWithArrow, actionType: .autoRechargTime)
        ]
         
        return [ section0, section1 ]
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.backgroundColor = .fzUIKit.primaryBackground
        view.showsVerticalScrollIndicator = false
        view.tableFooterView = UIView()
        view.separatorStyle = .none
        view.alwaysBounceVertical = false
        view.estimatedRowHeight = 100
        view.register(FZCommonTableCell.self, forCellReuseIdentifier: FZCommonTableCell.reuseIdentifier)
        view.dataSource = self
        view.delegate = self
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return view
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarView.titleLabel.text = L10n.txtAutoRechargeSetting
 
        darkLightStyle()

        setupUI()
         
        updateTypeUI()
         
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchTimeSwitchInfo()
    }
      
}

extension SEGen2AutoRechargeSettingVC{
    
    func updateTypeUI(){
        
        cardProcessor?.$robotSettingsReport.sink(receiveValue: {[weak self] model in
            guard let weakSelf = self else { return }
            if let mo = model, let t = mo.chargeType {
 
                weakSelf.items.update(row: .autoRechargManual, isTicked: t == 0)
                weakSelf.items.update(row: .autoRechargAuto, isTicked: t == 1)

                weakSelf.tableView.reloadData()
            }
        }).store(in: &self.cancellables)
         
    }
    
    func fetchTimeSwitchInfo(){
        
        cardProcessor?.ackCompletedDataHandler = {[weak self] data in
            if let dic = data as? [String: Any], let hour = dic["hour"] as? Int,
               let min = dic["min"] as? Int, let isOn = dic["isOn"] as? Bool{
                
                guard let weakSelf = self else { return }
                 
                let str = String(format: "%02d", hour) + ":" + String(format: "%02d", min)
                
                weakSelf.settingMin = min
                weakSelf.settingHour = hour
                weakSelf.settingIsOn = isOn
                 
                weakSelf.items.update(row: .autoRechargSwitch, isOn: isOn)
                weakSelf.items.update(row: .autoRechargTime, valueStr: str)
                
                weakSelf.tableView.reloadData()
            }
        }
        cardProcessor?.send(command: .timedAutoRechargeReq) 
    }
    
    func modifyType(t: Int){
         
        items.update(row: .autoRechargManual, isTicked: t == 0)
        items.update(row: .autoRechargAuto, isTicked: t == 1)

        tableView.reloadData()
        
        cardProcessor?.ackCompletedHandler = {[weak self] state in
             
            self?.view.toast(state == 0 ? L10n.txtXEditSuccess : L10n.txtSetupFailed)
        }
        
        cardProcessor?.send(command: .setAutoRechargeType(type: t))
    }
}

extension SEGen2AutoRechargeSettingVC: SEGen2AutoRechargeTimePickerSheetDelegate{
    
    func timePickerDidSelected(hour: Int, min: Int) {
        
        setting(hour: hour, min: min)
    }
    
}
 
extension SEGen2AutoRechargeSettingVC{
    
    func setting(isOn: Bool? = nil, hour: Int? = nil, min: Int? = nil){
          
        if let ison = isOn{
            settingIsOn = ison
             
            items.update(row: .autoRechargSwitch, isOn: ison)
        }
        
        if let h = hour, let m = min {
            settingMin = m
            settingHour = h
            let str = String(format: "%02d", h) + ":" + String(format: "%02d", m)

            items.update(row: .autoRechargTime, valueStr: str)
        }
        
        cardProcessor?.ackCompletedHandler = { [weak self] state in
            let str = state == 0 ? L10n.txtXEditSuccess : L10n.txtSetupFailed
            self?.view.toast(str)
        }
        cardProcessor?.send(command: .setTimedAutoRecharge(hour: settingHour, min: settingMin, isOn: settingIsOn))

        tableView.reloadData()
    }
     
    private func setupUI(){
          
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 16.adapt, left: 0, bottom: 0, right: 0))
        }
    }
    
}

extension SEGen2AutoRechargeSettingVC: FZCommonTableCellDelegate{
    func cellSwitchDidToggled(isOn: Bool, indexPath: IndexPath) {
        // tdoo
        setting(isOn: isOn)
    }
    
    func cellTickBtnDidToggled(isSelected: Bool, indexPath: IndexPath) {
        let models = items[indexPath.section]
        let model = models[indexPath.row]
        
        if model.actionType == .autoRechargManual{
            
            modifyType(t: 0)
        }else{
            
            modifyType(t: 1)
        }
    }
    
    
}

extension SEGen2AutoRechargeSettingVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let models = items[indexPath.section]
        let model = models[indexPath.row]
        
        guard model.selectRowEnable else { return }
        
        switch model.actionType {
            case .autoRechargTime:
                let v = SEGen2AutoRechargeTimePickerSheet()
                v.delegate = self
                v.mainViewHeight = 360
                v.sheetTitle = L10n.txtRechargeTime
                v.show(on: self)
            case .autoRechargManual, .autoRechargAuto:
                cellTickBtnDidToggled(isSelected: true, indexPath: indexPath)
                
            default:
                break
        }
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let models = items[indexPath.section]
        let model = models[indexPath.row]
        
        guard let guardCell = tableView.dequeueReusableCell(withIdentifier: FZCommonTableCell.reuseIdentifier) as? FZCommonTableCell else {
            return FZCommonTableCell(style: .default, reuseIdentifier: FZCommonTableCell.reuseIdentifier)
        }
        
        guardCell.delegate = self
        guardCell.config(with: model) 
        guardCell.updateRadius(16, currentSectionCellCount: models.count, correntRow: indexPath.row)
//        guardCell.updateTitleLabelTopConstraint(model: model)
        
        return guardCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let models = items[indexPath.section]
        let model = models[indexPath.row] 
        return model.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.frame = CGRect(x: 0, y: 0, width: ScreenUtils.screenWidth, height: 16.adapt)
        return v
    }
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return FZCommonTableCellItem.sectionHeaderHeight(by: "")
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return FZCommonTableCellItem.footerHeight()
    }
}
