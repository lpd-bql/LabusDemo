//
//  xxxxx.swift
//  LubasApp
//
//  Created by lpd on 2024/11/12.
//

import UIKit
import MJRefresh

protocol ListRefreshable: AnyObject{
    // 泛型约束，需在外部指定 ，使得 适用于 TableView和 CollectionView；
    associatedtype ScrollViewType: UIScrollView
    var scrollView: ScrollViewType! { get }
    
    
    func setupPullToRefresh(action: @escaping () -> Void)
    func setupLoadMore(action: @escaping () -> Void)
    
    func endRefreshing()
    func endLoadingMore()
    func setNoMoreData()
    
    func resetNoMoreData()
}


extension ListRefreshable {
    
    func setupPullToRefresh(action: @escaping () -> Void) {
        scrollView.mj_header = MJRefreshNormalHeader {
            action()
        }
    }
    
    func setupLoadMore(action: @escaping () -> Void) {
        scrollView.mj_footer = MJRefreshAutoNormalFooter {
            action()
        }
    }
    
    func endRefreshing() {
        scrollView.mj_header?.endRefreshing()
    }
    
    func endLoadingMore() {
        scrollView.mj_footer?.endRefreshing()
    }
    
    func setNoMoreData() {
        scrollView.mj_footer?.endRefreshingWithNoMoreData()
    }
    
    func resetNoMoreData() {
        scrollView.mj_footer?.resetNoMoreData()
    }
}
