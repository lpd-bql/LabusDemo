//
//  xxxxxxx.swift
//  LubasApp
//
//  Created by lpd on 2024/11/12.
//

import UIKit
import MJRefresh

class MyTableViewController: BaseViewController, ListRefreshable {
    typealias ScrollViewType = UITableView  // 指定
    var scrollView: UITableView! {
        return tableView
    }
    
    private var pageNo = 1
    private var pageSize = 12
    private var data = [String]()
    
    
   lazy var tableView: UITableView = {
       let tableView = UITableView(frame: .zero, style: .plain)
       tableView.separatorStyle = .none
       tableView.backgroundColor = .white
       tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
       tableView.rowHeight = 80
       tableView.dataSource = self
       tableView.delegate = self
       return tableView
   }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshAndLoadMore()
        
        loadData(isRefresh: true)
    }
    
    // 添加刷新
    private func setupRefreshAndLoadMore() {
        setupPullToRefresh { [weak self] in
            self?.resetNoMoreData()
            self?.pageNo = 1
            self?.loadData(isRefresh: true)
        }
        
        setupLoadMore { [weak self] in
            self?.pageNo += 1
            self?.loadData(isRefresh: false)
        }
    }
    
    private func loadData(isRefresh: Bool) {
        // 模拟网络请求
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            let newItems = (0..<self.pageSize).map { "Item \((self.pageNo - 1) * self.pageSize + $0)" }
            
            DispatchQueue.main.async {
                if isRefresh {
                    self.data = newItems
                    self.endRefreshing()
                } else {
                    self.data += newItems
                    self.endLoadingMore()
                    
                    if newItems.count < self.pageSize {
                        self.setNoMoreData()
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
}


extension MyTableViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
    
    
}
