//
//  xxx.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/19.
//

import Kingfisher

extension UIImageView{
    
    func loadImage(urlString: String){
        kf.indicatorType = .activity  // 显示系统菊花
        kf.setImage(with: URL(string: urlString))
    }
    
    func loadImage(urlString: String, placeholder: UIImage){
        
        kf.indicatorType = .activity  // 显示系统菊花
        kf.setImage(with: URL(string: urlString), placeholder: placeholder)
        
    }
    
    func loadImage(urlString: String, placeholder: UIImage, complete: @escaping ()->()){
        
        kf.indicatorType = .activity  // 显示系统菊花
        kf.setImage(with: URL(string: urlString), placeholder: placeholder) { result in
            complete()
        }
    }
    
    
    
}
