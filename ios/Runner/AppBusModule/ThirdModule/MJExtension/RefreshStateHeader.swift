//
//  RefreshStateHeader.swift
//  AIRun
//
//  Created by AIRun on 20248/14.
//

import UIKit
import NVActivityIndicatorView

class RefreshStateHeader: MJRefreshStateHeader {

    // MARK: - 属性声明
    override func prepare() {
        super.prepare()
        self.addSubview(indicatorView)
        self.stateLabel?.isHidden = true
    }
    
    override func placeSubviews() {
        super.placeSubviews()
    }
    
    override var state: MJRefreshState {
        didSet {
            if state == .idle {
                indicatorView.stopAnimating()
            }else {
                indicatorView.startAnimating()
            }
        }
    }
    
    lazy var indicatorView: NVActivityIndicatorView = {
        let v = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: 50), type: .ballClipRotatePulse, color: UIColor.appPinkColor(), padding: 10)
        return v
    }()
}


