//
//  FoldingModel.swift
//  TableGroupFoldingProject
//
//  Created by zhifu360 on 2019/5/28.
//  Copyright © 2019 ZZJ. All rights reserved.
//

import UIKit

class FoldingModel: NSObject {

    var title: String?//标题
    var isShow: Bool?//是否展开
    var methodDataSource: NSArray!//方法数组
    
    class func initModel(title: String?, isShow: Bool?, methodData: NSArray?) -> FoldingModel {
        let model = FoldingModel()
        model.title = title
        model.isShow = isShow
        model.methodDataSource = methodData
        return model
    }
    
}
