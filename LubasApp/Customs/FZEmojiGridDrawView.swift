//
//  FZEmojiGridDrawView.swift
//  ElmApp
//
//  Created by lpd on 2025/1/20.
//  Copyright © 2025 Enabot Technology (Shenzhen) Company Limited. All rights reserved.
//
import UIKit

protocol FZEmojiGridDrawViewDelegate: AnyObject{
    func removeEmojiDraw()
}

class FZEmojiGridDrawView: UIView{
    weak var delegate: FZEmojiGridDrawViewDelegate?
    
    var width: CGFloat = 1.0
     
    var emojiValueHexStrTemp = ""

    var selectedStateArr: [UInt8] = Array(repeating: 0x00, count: 7) // 7 行 选中状态

    private var panGesture: UIPanGestureRecognizer!
    
    lazy var cornersIndexPaths: Set<IndexPath> = {
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
            "iconArrowUp", "iconArrowDown", "iconArrowLeft", "iconArrowRight", "iconArrowC", "SE2DeleteIcon",
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
extension FZEmojiGridDrawView{
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location) else { return }

        switch gesture.state {
        case .began, .changed:
            updateState(for: indexPath, isSelected: true)
            
        case .ended:
            break
        default:
            break
        }
    }
     
    
    @objc func btnAction(_ btn: UIButton){
        let tag = btn.tag
        
        switch tag {
            case 10:
                // 上
                shiftUp()
            case 11:
                // 下
                shiftDown()
            case 12:
                    // 左
                shiftLeft()
            case 13:
                // 右
                shiftRight()
            case 14:
                // 旋转
                rotate()
            default:
                // 删除
                delegate?.removeEmojiDraw()
        }
        
    }
    
     
    private func shiftLeft() {
        for row in 0..<selectedStateArr.count {
            selectedStateArr[row] <<= 1
            selectedStateArr[row] &= 0x7F // 清除越界位
        }
        collectionView.reloadData()
    }

    private func shiftRight() {
        for row in 0..<selectedStateArr.count {
            selectedStateArr[row] >>= 1
        }
        collectionView.reloadData()
    }

    private func shiftUp() {
        selectedStateArr.removeFirst()
        selectedStateArr.append(0x00)
        collectionView.reloadData()
    }

    private func shiftDown() {
        selectedStateArr.removeLast()
        selectedStateArr.insert(0x00, at: 0)
        collectionView.reloadData()
        
    }

    private func rotate() {
        var newState: [UInt8] = Array(repeating: 0x00, count: 7)
                
        for row in 0..<7 {
            for col in 0..<7 {
                let bitMask: UInt8 = 1 << (6 - col)
                if selectedStateArr[row] & bitMask != 0 {
                    let newRow = 6 - col
                    let newCol = row
                    newState[newRow] |= 1 << (6 - newCol)
                }
            }
        }
        
        selectedStateArr = newState
        collectionView.reloadData()
    }
     
}


extension FZEmojiGridDrawView: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        7 * 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath) as? UICollectionViewCell else { return UICollectionViewCell() }
        
        if cornersIndexPaths.contains(indexPath){
            // 隐藏 四个角
            cell.contentView.backgroundColor = UIColor.gray
        }
        else{
            checkSeletedUI(for: cell, at: indexPath)
        }
        
 
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateState(for: indexPath, isSelected: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateState(for: indexPath, isSelected: false)
        
    }
     
}

extension FZEmojiGridDrawView{
    
    private func updateState(for indexPath: IndexPath, isSelected: Bool) {
        let totalColumns = 7
        let row = indexPath.item / totalColumns
        let col = indexPath.item % totalColumns
        let bitMask: UInt8 = 1 << (6 - col)
        // 数据
        if isSelected {
            selectedStateArr[row] |= bitMask
        } else {
            selectedStateArr[row] &= ~bitMask
        }
        emojiValueHexStrTemp = generateHexRepresentation()

        // UI
        if let cell = collectionView.cellForItem(at: indexPath) {
            checkSeletedUI(for: cell, at: indexPath)
        }
         
    }
    
    private func checkSeletedUI(for cell: UICollectionViewCell, at indexPath: IndexPath) {
        let totalColumns = 7
        let row = indexPath.item / totalColumns
        let col = indexPath.item % totalColumns
        let bitMask: UInt8 = 1 << (6 - col)
        
        let isSelected = (selectedStateArr[row] & bitMask) != 0
        cell.contentView.backgroundColor = isSelected ? UIColor.yellow : UIColor.gray
    }
    
    
    private func generateHexRepresentation() -> String {
        return selectedStateArr.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - public
extension FZEmojiGridDrawView{
     
    func setSelectedState(bytes: [UInt8]){
        selectedStateArr = bytes
        // 更新 UI
        collectionView.reloadData()
    }
    
    func setSelectedState(from hexString: String) {
        // 将十六进制字符串解析为 [UInt8]
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
     
    
    func reset(){
        selectedStateArr = Array(repeating: 0x00, count: 7)
        collectionView.reloadData()
    }
}

 
