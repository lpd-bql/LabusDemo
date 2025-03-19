//
//  FZPopupMenuListView.swift
//  ElmApp
//
//  Created by lpd on 2025/1/24.
//  Copyright © 2025 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//



class FZPopupMenuListView: UIView{
    var selectedRowAction: ((Int) -> Void)?
    
    var dataSource: [String] = []
    var selectedIndex = 0
    
    lazy var tableView: UITableView = {
        let tbv = UITableView(frame: .zero, style: .plain)
        tbv.showsVerticalScrollIndicator = false
        tbv.backgroundColor = .clear
        tbv.separatorColor = .fzUIKit.quaternaryBackground
        tbv.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        tbv.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tbv.tableFooterView = UIView()
        tbv.dataSource = self
        tbv.delegate = self
        tbv.rowHeight = 30.adapt
        tbv.layer.cornerRadius = 8
        tbv.layer.masksToBounds = true
        return tbv
    }()
    
    init(frame: CGRect, dataSource: [String]) {
        super.init(frame: frame)
        self.dataSource = dataSource
        
        addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    @objc func tapViewDismiss(){
        self.removeFromSuperview()
    }
     
     
    public func setSelectedIndex(idx: Int){
        selectedIndex = idx
        tableView.reloadData()
    }
}

extension FZPopupMenuListView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let guardCell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") as? UITableViewCell else {
            let cell = UITableViewCell()
            return cell
        }
        let str = dataSource[indexPath.row]
        guardCell.textLabel?.text = str
        guardCell.textLabel?.font = 14.fontEBO(.regular)
        guardCell.backgroundColor = .clear
        guardCell.contentView.backgroundColor = .fzUIKit.secondaryBackground

        if selectedIndex == indexPath.row {
            guardCell.textLabel?.textColor = .fzUIKit.primary
        }else{
            guardCell.textLabel?.textColor = .fzUIKit.primaryText
        }
        
        return guardCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        self.isHidden = true
        tableView.reloadData()
        selectedIndex = indexPath.row
        selectedRowAction?(selectedIndex)
        
        self.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == dataSource.count - 1{
            // 隐藏最后一个cell的 分割线
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
    }
}
