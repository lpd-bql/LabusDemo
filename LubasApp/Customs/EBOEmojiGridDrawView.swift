//
//  EBOEmojiGridDrawView.swift
//  ElmApp
//
//  Created by lpd on 2025/1/20.
//  Copyright © 2025 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//

import UIKit


protocol EBOEmojiGridDrawViewDelegate: AnyObject{
    func removeEmojiDraw()
}

class EBOEmojiGridDrawView: UIView{
    weak var delegate: EBOEmojiGridDrawViewDelegate?
    
    var width: CGFloat = 1.0
     
    var emojiValueHexStrTemp = ""
    
    /// 用UInt8 数组 保存每个cell的选中状态，1-选中，0未选中
    ///  本次需求，以 列 为单位 ，高位在下，低位在上，
    ///  如:  selectedStateArr[2] = 0x02 表示 第矩阵第3列的 第1行被选中；selectedStateArr[2] = 0x40 表示 第矩阵第3列的 第6行被选中
    var selectedStateArr: [UInt8] = Array(repeating: 0x00, count: 7)
    
    /// 按以上需求规律，给 每行配 二进制掩码；用于做 位运算
    private func bitMask(for row: Int) -> UInt8 {
        return 2 << row   //   00000010  << row
//        switch row {
//            case 0: return 0b00000010
//            case 1: return 0b00000100
//            case 2: return 0b00001000
//            case 3: return 0b00010000
//            case 4: return 0b00100000
//            case 5: return 0b01000000
//            case 6: return 0b10000000
//            default: return 0
//        }
    }
     
    /// selectedStateArr 的 所有UInt8值，转为 十六进制字符串
    private var selectedStateHexString: String{
         
        return selectedStateArr.map { String(format: "%02x", $0) }.joined()
    }

    private var panGesture: UIPanGestureRecognizer!
    
    lazy var indexPathsNeedOverlook: Set<IndexPath> = {
        var sets = Set<IndexPath>()
        sets.insert(IndexPath.init(row: 0, section: 0))
        sets.insert(IndexPath.init(row: 6, section: 0))
        sets.insert(IndexPath.init(row: 42, section: 0))
        sets.insert(IndexPath.init(row: 48, section: 0))
        return sets
    }()

    lazy var contentViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let perw = self.width / 7.0
        let w = 2.0/3.0 * perw
        let padding = 1.0/3.0 * perw
        
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        layout.itemSize = CGSize(width: w, height: w )
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return layout
    }()
  
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: contentViewLayout)
        view.dataSource = self
        view.delegate = self
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.allowsMultipleSelection = true
        return view
    } ()
    
    lazy var toolBar: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.distribution = .equalSpacing
        v.alignment = .center
        
        let icons = [
            "iconArrowUp", "iconArrowDown", "iconArrowLeft", "iconArrowRight", "iconArrowC", "iconDeleteWhite",
        ]
        
        for (idx, str) in icons.enumerated(){
            let b = UIButton()
            b.setImage(.init(named: str), for: .normal)
            b.tag = 10 + idx
            b.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
            v.addArrangedSubview(b)
        }
        
        return v
    }()
    
    init(frame: CGRect, width: CGFloat, editAble: Bool) {
        self.width = width
        super.init(frame: frame)
 
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(width)
        }
        
        if editAble {
            // 实现 滑动 操作
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            collectionView.addGestureRecognizer(panGesture)
        }else{
            collectionView.isUserInteractionEnabled = false
        }
        
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
      
}

// MARK: - action
extension EBOEmojiGridDrawView{
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location) else { return }

        switch gesture.state {
        case .began, .changed:
                didPanned(at: indexPath)
        case .ended:
            break
        default:
            break
        }
    }
     
    private func didPanned(at indexPath: IndexPath){
        let row = indexPath.item / 7
        let col = indexPath.item % 7
        if isSelected(row: row, col: col) || indexPathsNeedOverlook.contains(indexPath) {
            return  // 如果是四个角的cell 或 已选中（为了优化划选 体验
        }
         
        toggleSelection(at: indexPath)
    }
    
    @objc func btnAction(_ btn: UIButton){
        switch btn.tag {
            case 10:
                shiftUp()  // 上
            case 11:
                shiftDown()  // 下
            case 12:
                shiftLeft() // 左
            case 13:
                shiftRight() // 右
            case 14:
                rotate()  // 逆时针旋转
            default:
                // 删除
//                delegate?.removeEmojiDraw()
                reset()
        }
    }
    
     
    private func shiftLeft() {
        selectedStateArr.removeFirst()
        selectedStateArr.append(0x00)
        cleanSomeValue()
        collectionView.reloadData()
    }

    private func shiftRight() {
        // 右移，即把 第7列移除，在开头补充一列
        selectedStateArr.removeLast()
        selectedStateArr.insert(0x00, at: 0)
        
        cleanSomeValue()
        collectionView.reloadData()
        
    }

    private func shiftUp() {
        for row in 0..<selectedStateArr.count {
            selectedStateArr[row] >>= 1
            selectedStateArr[row] &= 0xFE // 清除越界位
        }
        cleanSomeValue()
        collectionView.reloadData()
    }

    private func shiftDown() {
        for row in 0..<selectedStateArr.count {
            // 根据 高位在下，低位在上，下移需要 做 << 操作  0000 0010  左移1位 即 0000 0100
            selectedStateArr[row] <<= 1
            selectedStateArr[row] &= 0xFE // 清除越界位
        }
        cleanSomeValue()
        collectionView.reloadData()
    }

    private func rotate() {
        // 构造旋转后的 UInt8数组
        var newStates: [UInt8] = Array(repeating: 0x00, count: 7)
                
        for col in 0..<7 {
            for row in 0..<7 {
                let bitMask = bitMask(for: row)  // 获取当前行的bit
                if (selectedStateArr[col] & bitMask) != 0 {
                    // 顺时针 转换规则
//                    let newCol = 6 - row // 新列 = 6 - 旧行
//                    let newRow = col // 新行 = 旧列
                    // 逆时针
                    let newCol = row // 新列 = 旧行
                    let newRow = 6 - col // 新行 = 6 - 旧列
                    
                    let newBitMask = self.bitMask(for: newRow)  // 计算新位置的bit
                    newStates[newCol] |= newBitMask // 或运算 , 不会覆盖掉 已经选中的 位。这里不能用 异或
                }
            }
        }
        
        selectedStateArr = newStates
        cleanSomeValue()
        collectionView.reloadData()
    }
     
}


extension EBOEmojiGridDrawView: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        7 * 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath) as? UICollectionViewCell else { return UICollectionViewCell() }
        
        if indexPathsNeedOverlook.contains(indexPath){
            // 隐藏 四个角
            cell.contentView.backgroundColor = UIColor.black
        }
        else{
            checkSeletedUI(for: cell, at: indexPath)
        }
 
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPathsNeedOverlook.contains(indexPath) { return }  // 忽略四个角
        
        toggleSelection(at: indexPath)
    }
     
}

extension EBOEmojiGridDrawView{
     
    // 选中；反选
    private func toggleSelection(at indexPath: IndexPath) {
        let row = indexPath.item / 7  // 计算行（0-6）
        let col = indexPath.item % 7  // 计算列（0-6）
        
        let mask = bitMask(for: row)
        // 跟 掩码进行 异或运算，1->0，0->1, 实现反选效果
        selectedStateArr[col] ^= mask
        cleanSomeValue()
        
        emojiValueHexStrTemp = selectedStateHexString
//        debugPrint("pdddddo: ", emojiValueHexStrTemp)
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            checkSeletedUI(for: cell, at: indexPath)
        }
    }
    
    // 切换 选中样式
    private func checkSeletedUI(for cell: UICollectionViewCell, at indexPath: IndexPath) {
        let row = indexPath.item / 7  // 计算行（0-6）
        let col = indexPath.item % 7  // 计算列（0-6）
//        debugPrint("pddddd row: ", row)
//        debugPrint("pddddd col: ", col)

        let isSelected = isSelected(row: row, col: col)
        
        cell.contentView.backgroundColor = isSelected ? UIColor.yellow : UIColor.gray
    }
    
    // 判断 cell是否选中
    private func isSelected(row: Int, col: Int) -> Bool {
        // 跟 掩码进行 与运算，如果结果 != 0， 表示 该为 为1，即 该位为选中状态
        let isSelected = (selectedStateArr[col] & bitMask(for: row)) != 0

        return isSelected
    }
    
    
    // 使矩阵 四个角的Cell 始终保持非选中状态
    private func cleanSomeValue() {
        let fixedIndices = [(0, 0), (0, 6), (6, 0), (6, 6)]
        for (row, col) in fixedIndices {
            let bitMask = bitMask(for: row)
            // 先对bitMask取反，使得该行对应位变 0，其他位保持不变
            // 无论 0,1，跟0进行与运算，都是0，达到 始终保持非选中状态 的目的
            selectedStateArr[col] &= ~bitMask
            
        }
    }
      
}

// MARK: - public
extension EBOEmojiGridDrawView{
     
    func setSelectedState(bytes: [UInt8]){
        selectedStateArr = bytes
        // 更新 UI
        collectionView.reloadData()
    }
    
    func setSelectedState(from hexString: String) {
        // 将十六进制字符串 如：08fe28488c4868 ，解析为 [UInt8]
        let bytes = stride(from: 0, to: hexString.count, by: 2).compactMap { index -> UInt8? in
            
            let start = hexString.index(hexString.startIndex, offsetBy: index)
            let end = hexString.index(start, offsetBy: 2)
            let byteString = String(hexString[start..<end])
            
            return UInt8(byteString, radix: 16)
        }
        
        // 确保解析结果为 7 个字节
        guard bytes.count == 7 else {
            print("Invalid hex string: \(hexString)")
            return
        }
        
        setSelectedState(bytes: bytes)
    }
     
    // 复位
    func reset(){
        selectedStateArr = Array(repeating: 0x00, count: 7)  // 0表示 未选中，1表示选中
        emojiValueHexStrTemp = selectedStateHexString
//        print("pdd emojiValueHexStrTemp: ", emojiValueHexStrTemp)
        collectionView.reloadData()
    }
}

 
