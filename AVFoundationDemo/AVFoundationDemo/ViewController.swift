//
//  ViewController.swift
//  AVFoundationDemo
//
//  Created by yy on 2019/9/16.
//  Copyright © 2019 Jackfrow. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return dataSource.count
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell  = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = dataSource[indexPath.row]
        
        return cell ?? UITableViewCell()
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
       
        let title = dataSource[indexPath.row]
        

        var vc: UIViewController?
        
        if title == "视屏播放" {
            
            vc = PlayViewController()
            
        }else if title == "视屏录制"{
            
            vc = RecordViewController()
            
        }else if title == "视屏拼接"{
            
            vc = MergeViewController()
            
        }else if title == "添加水印"{
            
            vc = AddSubTitleViewController()
            
        }else if title == "添加动画"{
            
            vc = AddAnimationViewController()
            
        }else if title == "添加过渡效果"{

            vc = TransitionViewController()
        }
        
        if let vc = vc {
             navigationController?.pushViewController(vc, animated: true)
        }
    
    }

    lazy var dataSource: [String] = {
        
        let items = ["视屏播放","视屏录制","视屏拼接","添加水印","添加动画","添加过渡效果"]
        
        return  items
        
    }()
    
}


