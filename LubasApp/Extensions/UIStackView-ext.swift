//
//  UIStackView-ext.swift
//  LubasApp
//
//  Created by lpd on 2025/1/23.
//

import UIKit

extension UIStackView{
    
    func horizonStack() -> UIStackView{
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
}
