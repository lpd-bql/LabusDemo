//
//  xxxx.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/15.
//

import Foundation
import UIKit
import SnapKit

class BaseViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.isHidden = true
    }
    
}
