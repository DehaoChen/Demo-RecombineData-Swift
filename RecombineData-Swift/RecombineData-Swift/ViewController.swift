//
//  ViewController.swift
//  RecombineData-Swift
//
//  Created by chendehao on 16/8/8.
//  Copyright © 2016年 CDHao. All rights reserved.
//

import UIKit
import MJExtension

class ViewController: UIViewController {
    
    // 数组属性
    lazy var carBrandItems : [CDH_CarBrandItem]? = {
        
        // 读取数据
        let path : String? = NSBundle.mainBundle().pathForResource("brand", ofType: "plist")
        guard let filePath = path else {
            return nil
        }
        
        let dictionaryData : NSDictionary? = NSDictionary(contentsOfFile: filePath)
        guard let dictionary = dictionaryData else {
            return nil
        }
        
        guard let dictArray = (dictionary["data"]) as? [[String : NSObject]] else{
            return nil
        }
        
        
        // 定义一个临时的数组
        var carBrandItems : [CDH_CarBrandItem] = [CDH_CarBrandItem]()
        
        // 字典转模型
        for dict in dictArray {
            let carBrandItem = CDH_CarBrandItem()
            carBrandItem.Letter = dict["Letter"] as! String
            carBrandItem.Name = dict["Name"] as! String
            carBrandItem.Pbid = dict["Pbid"] as! String
            carBrandItems.append(carBrandItem)
        }
        
        return carBrandItems
    }()
    var carGroupItems : [CDH_CarGroupItem] = [CDH_CarGroupItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 重新分组
        carGroupItems = self.regroupItemWithArray(self.carBrandItems!)
        
        // 将重新分组后的 写 plist 文件
        let flag = self.modelArrayTransferToDictionaryArray(carGroupItems)
        
        print(flag)
        
        // 添加tableView
        self.setUpChildViews()
        
        
        
    }
}



// MARK : - 重新分组 以及写 plist 文件
extension ViewController {
    // 重新分组
    func regroupItemWithArray ( array : [CDH_CarBrandItem]) -> [CDH_CarGroupItem] {
        // 重新分组后的数组
        var reGroupItems : [CDH_CarGroupItem]? = [CDH_CarGroupItem]()
        
        // 取出数组 carBrandItems 中的数据进行分组
        for var carBrandItem in array  {
            
            // 创建一个车模型
            let carItem : CDH_CarItem = CDH_CarItem()
            carItem.Name = carBrandItem.Name
            carItem.Pbid = carBrandItem.Pbid
            
            // 用一个标识符标识遍历到 carGroupItems 数组中是有已经有 Letter 属性这样的对象了,
            // 如果有直接追加数据, 如果没有则创建一个 CDH_CarGroupItem 对象并添加响应的数据
            var flagLetter = false

            // 遍历找出 carGroupItems 数组中 CDH_CarGroupItem 模型里的 Letter 的值比较
            for var carGroupItem in reGroupItems! {
                
                // 比较是字符串是否相等,
                // 比较如果相等, 则直接在该对象的数组属性 cars 中添加一个 CDH_CarItem 对象,并且 break 掉遍历
                // 比较如果不相等, 则直接添加一个 CDH_CarGroupItem 类型的对象到 carGroupItems 中
                if carGroupItem.Letter == carBrandItem.Letter {
                    flagLetter = true // 已经遍历到相应的数据
                    carGroupItem.cars.append(carItem) // 添加到数据模型中
                    break; // 退出遍历
                }
            }
            // 没有遍历到对应的数据这要追加
            if !flagLetter {
                
                // 创建一个模型用来存储重新分组的 car 模型
                let carGroupItem  = CDH_CarGroupItem()
                
                carGroupItem.Letter = carBrandItem.Letter
                carGroupItem.cars.append(carItem)
                
                // 并将该模型添加到数组中
                reGroupItems?.append(carGroupItem)
            }
        }
        return reGroupItems!
    }
    
    // 写 plist文件
    func modelArrayTransferToDictionaryArray(array : [CDH_CarGroupItem]) -> Bool {
        
        let dictCarGroupItems = NSMutableArray(capacity: carGroupItems.count)
        for var carGroupItem in array {
            let dictCarGroupItem = carGroupItem.mj_keyValues()
            
            dictCarGroupItems.addObject(dictCarGroupItem)
        }
        
        // 写数据 plist 文件
        return dictCarGroupItems.writeToFile("/Users/chendehao/Desktop/swift-dictArrayCarGroups.plist", atomically: true)
        
    }
}


// MARK : - 添加子控件
extension ViewController {
    func setUpChildViews() -> Void {
        let tableView = UITableView()
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
    }
}

// MARK : - TableViewDelegate & UITableViewDataSource
extension ViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var carGroupItem : CDH_CarGroupItem = carGroupItems[section]
        
        return carGroupItem.cars.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.carGroupItems.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let ID = "carBrandCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(ID)
        if cell == nil {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: ID)
        }
        
        let carGroupItem = carGroupItems[indexPath.section]
        let car = carGroupItem.cars[indexPath.row]
        
        cell?.textLabel?.text = car.Name
        cell?.detailTextLabel?.text = car.Pbid
        
        return cell!
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // 获取到组数
        let carGroupItem = carGroupItems[section]
        return carGroupItem.Letter
    }
}
