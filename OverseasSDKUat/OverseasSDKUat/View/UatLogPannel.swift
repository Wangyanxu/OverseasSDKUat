//
//  PRTCLogPannel.swift
//  OverseasSDKUat
//
//  Created by wangyanxu on 2024/11/5.
//

import UIKit

class UatLogPannel: UIView {
    
    private var textView: UITextView!
    private var formatter: DateFormatter?
    
    static let shared = UatLogPannel.pannel()
    
    static func pannel() -> UatLogPannel {
        let pannel = UatLogPannel(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 150, width: UIScreen.main.bounds.width, height: 100))
        
        // Initialize UITextView
        let textView = UITextView(frame: pannel.bounds)
        textView.textColor = UIColor(red: 40/255.0, green: 40/255.0, blue: 40/255.0, alpha: 1.0)
        textView.isEditable = false
        pannel.addSubview(textView)
        pannel.textView = textView
        
        // Add close button
        let close = UIButton(frame: CGRect(x: pannel.bounds.width - 30, y: 10, width: 10, height: 10))
        close.accessibilityIdentifier = "closeLog"
        close.layer.cornerRadius = 5
        close.layer.masksToBounds = true
        close.backgroundColor = .red
        close.addTarget(pannel, action: #selector(pannel.dismiss), for: .touchUpInside)
        pannel.addSubview(close)
        
        return pannel
    }
    
    // MARK: - Logging
    static func log(_ content: String) {
        DispatchQueue.main.async {
            let pannel = UatLogPannel.shared
            
            if pannel.formatter == nil {
                pannel.formatter = DateFormatter()
                pannel.formatter?.dateFormat = "HH:mm:ss"
            }
            
            if let formattedDate = pannel.formatter?.string(from: Date()) {
                let log = "\(formattedDate) \(content)"
                pannel.textView.text = "\(log)\n\(pannel.textView.text ?? "")"
            }
        }
    }
    
    @objc private func dismiss() {
        self.removeFromSuperview()
    }
}

