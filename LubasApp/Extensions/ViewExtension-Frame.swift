//
//  UIView-Extension.swift
//  OpenBoy
//
//  Created by Mac on 2020/4/26.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import UIKit


extension UIView{
    
    /// 获取视图的x坐标
    public var x:CGFloat{
        get{
            return self.frame.origin.x
        }
        set{
            var fm = self.frame
            fm.origin.x = newValue
            self.frame = fm
        }
    }
    
    /// 获取视图的y坐标
    public var y:CGFloat{
        get{
            return self.frame.origin.y
        }
        set{
            var fm = self.frame
            fm.origin.y = newValue
            self.frame = fm
        }
    }
    
    /// 获取视图的宽度
    public var w: CGFloat{
        get{
            return self.frame.size.width
        }
        set{
            var frames = self.frame
            frames.size.width = newValue
            self.frame = frames
        }
    }
    
    /// 获取视图的高度
    public var h: CGFloat{
        get{
            return self.frame.size.height
        }
        set{
            var frames = self.frame
            frames.size.height = newValue
            self.frame = frames
        }
    }
    
    /// 获取视图的中心 x
    public var cX: CGFloat{
        get{
            return self.center.x
        }
        set{
            self.center = CGPoint(x:newValue,y:self.center.y)
        }
    }
    
    /// 获取视图的中心 y
    public var cY: CGFloat{
        get{
            return self.center.y
        }
        set{
            self.center = CGPoint(x:self.center.x,y:newValue)
        }
    }
    
}
