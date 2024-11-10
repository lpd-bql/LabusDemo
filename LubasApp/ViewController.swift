//
//  ViewController.swift
//  LubasApp
//
//  Created by Pidong Ling on 2021/12/28.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let v = UIView()
        v.backgroundColor = .green
        v.frame = .init(x: 33, y: 100, width: 333, height: 44)
        view.addSubview(v)
    }


}

