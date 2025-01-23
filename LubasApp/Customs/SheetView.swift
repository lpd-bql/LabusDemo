//
//  SheetView.swift
//  LubasApp
//
//  Created by lpd on 2025/1/23.
//


import SnapKit

class SheetView: UIViewController {
    // 创建时 设置：
    var mainViewHeight: CGFloat
    var sheetTitle = ""
    var confirmAction: ((Any?) -> Void)?
     
    lazy var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    lazy var rightBtn: UIButton = {
        let okBtn = UIButton()
        okBtn.setTitle("确认", for: .normal)
        okBtn.addTarget(self, action: #selector(okAction), for: .touchUpInside)
        return okBtn
    }()
     
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
     
     
    init(mainViewHeight: CGFloat = 1.0, sheetTitle: String = "") {
        self.mainViewHeight = mainViewHeight
        self.sheetTitle = sheetTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubview()
        
        titleLabel.text = sheetTitle
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        mainView.eboExtCornerRadius(radius: 16, corners: [.topLeft, .topRight])
    }
    
    private func setupSubview() {
        view.backgroundColor = .clear
        
        commentUI()
        
        customSubview()
    }
    
    @objc func okAction(){
        dismiss()
    }
    
    @objc func xAction(){
        dismiss()
    }
}

extension SheetView{
    
    private func commentUI(){
        let tapv = UIView()
        view.addSubview(tapv)
        tapv.frame = view.bounds
        let tapp = UITapGestureRecognizer.init(target: self, action: #selector(xAction))
        tapv.addGestureRecognizer(tapp)
        
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(mainViewHeight)
            make.height.equalTo(mainViewHeight)
        }
           
        let topBar = UIView()
        mainView.addSubview(topBar)
        mainView.addSubview(contentView)

        topBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        contentView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(topBar.snp.bottom)
        }
        
        
        let xBtn = UIButton()
        xBtn.setTitle("关闭", for: .normal)
        xBtn.addTarget(self, action: #selector(xAction), for: .touchUpInside)
        
        topBar.addSubview(xBtn)
        topBar.addSubview(rightBtn)
        topBar.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        rightBtn.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview()
            make.width.width.equalTo(40)
        }
        xBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.height.centerY.equalTo(rightBtn)
        }
    }
}


// MARK: public
extension SheetView{
    
    @objc func customSubview(){
        // 子类 重载
    }
    
    func show(on vc: UIViewController){
        
        self.modalPresentationStyle = .overFullScreen
        vc.present(self, animated: false) {
            self.mainView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(0)
            }
            UIView.animate(withDuration: 0.3) {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    func dismiss(){
        self.mainView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(mainViewHeight)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.view.layoutIfNeeded()
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    
    
}
  
