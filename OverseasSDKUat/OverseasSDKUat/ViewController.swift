//
//  ViewController.swift
//  OverseasSDKUat
//
//  Created by wangyanxu on 2024/11/4.
//

import UIKit


class ViewController: BaseViewController {

    /// 方法列表
    lazy var tableView: UITableView = {
        let table = UITableView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 150), style: .plain)
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: BaseTableReuseIdentifier)
        table.sectionHeaderHeight = 50
        table.rowHeight = 44
        table.separatorStyle = .none
        return table
    }()
    
//    /// 日志显示 button
//    lazy var showLogButton: UIButton = {
//
//    }
    
    var dataArray = [FoldingModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setView()
        requestAPI()
    }
    
    func setView() {
        title = "海外 UAT"
        view.addSubview(tableView)
        let logPanel = UatLogPannel.shared
        view.addSubview(logPanel)
    }

    /// 数据录入
    func requestAPI() {
        let methodDic = Bundle.readDataWith(fileName: "MethodData", fileType: "json")
        let dict = Bundle.readDataWith(fileName: "content", fileType: "json")
        let tmpArr = dict["data"] as! [[String: Any]]
        for item in tmpArr {
            let title = item["title"] as! String
            let model = FoldingModel.initModel(title: title, isShow: item["isShow"] as? Bool, methodData: methodDic[title] as? NSArray)
            dataArray.append(model)
        }
    }
    
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray[section].isShow == true ? dataArray[section].methodDataSource.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BaseTableReuseIdentifier, for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textColor = UIColor.black
        let methodDic = dataArray[indexPath.section].methodDataSource[indexPath.row] as! NSDictionary
        for key in methodDic.allKeys {
            if let keyString = key as? String, keyString != "参数" {
                cell.textLabel?.text = keyString
                break  
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SectionHeaderView(frame: CGRect(x: 0, y: 0, width: ScreenSize.width, height: 50), section: section, delegate: self, title: dataArray[section].title)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlertWithInput(indexPath)
    }
    
}

/// 弹窗
extension ViewController {
    func showAlertWithInput(_ indexPath: IndexPath) {
        let methodDic = dataArray[indexPath.section].methodDataSource[indexPath.row] as! NSDictionary

        let alertController = UIAlertController(title: methodDic.allKeys.first as? String, message: "以分号分割参数", preferredStyle: .alert)
           
           alertController.addTextField { (textField) in
               textField.placeholder = methodDic.object(forKey:"参数") as? String
           }
           
           let confirmAction = UIAlertAction(title: "确定", style: .default) { [weak alertController] _ in
               if let textField = alertController?.textFields?.first {
                   var methodName = ""
                   for key in methodDic.allKeys {
                       if let keyString = key as? String, keyString != "参数", let value = methodDic[key] {
                           methodName = value as? String ?? ""
                           break
                       }
                   }
                   // 获取类的类型
                   if let method = NSClassFromString("OverseasSDKUat.MethodCenter") as? NSObject.Type {
                       let selector = NSSelectorFromString(methodName)
                       
                       if method.responds(to: selector) {
                           method.perform(selector, with: textField.text ?? "")
                       } else {
                           print("Method not found")
                       }
                   }
                   else {
                       print("Class not found")
                   }
                   print("用户输入内容: \(textField.text ?? "")")
               }
           }
           let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
           
           alertController.addAction(confirmAction)
           alertController.addAction(cancelAction)
           alertController.view.translatesAutoresizingMaskIntoConstraints = false;
           self.present(alertController, animated: true, completion: nil)
       }
}
///  heard 折叠
extension ViewController: SectionHeaderViewDelegate {
    
    func sectionHeaderViewClick(sectionHeaderView: SectionHeaderView, section: Int) {
        let isShow = dataArray[section].isShow
        dataArray[section].isShow = !isShow!
                tableView.reloadSections(IndexSet(integer: section), with: .fade)
    }
    
}

