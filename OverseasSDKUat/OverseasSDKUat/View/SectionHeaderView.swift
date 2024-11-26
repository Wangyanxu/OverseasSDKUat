//
//  SectionHeaderView.swift
//  TableGroupFoldingProject
//
//  Created by zhifu360 on 2019/5/28.
//  Copyright © 2019 ZZJ. All rights reserved.
//

import UIKit

@objc protocol SectionHeaderViewDelegate: NSObjectProtocol {
    @objc optional
    func sectionHeaderViewClick(sectionHeaderView: SectionHeaderView, section: Int)
}

class SectionHeaderView: UIView {

    weak var delegate: SectionHeaderViewDelegate?
    
    var titleText: String?
    
    ///创建UILabel
    lazy var label: UILabel = {
        let lb = UILabel(frame: self.bounds)
        lb.font = UIFont.systemFont(ofSize: 18)
        lb.textColor = UIColor.white
        lb.textAlignment = NSTextAlignment.center
        lb.text = self.titleText
        return lb
    }()
    
    var section: Int = 0
    
    init(frame: CGRect, section: Int, delegate: SectionHeaderViewDelegate?, title: String?) {
        super.init(frame: frame)
        self.section = section
        self.delegate = delegate
        self.titleText = title
        backgroundColor = UIColor.lightGray
        addViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViews() {
        addSubview(label)
        
        //添加手势
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
    }

    @objc func tap(_ tapGesture: UITapGestureRecognizer) {
        if delegate != nil {
            delegate?.sectionHeaderViewClick?(sectionHeaderView: self, section: section)
        }
    }
    
}
