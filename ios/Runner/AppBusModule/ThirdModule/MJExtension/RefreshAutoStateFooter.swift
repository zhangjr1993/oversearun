//
//  RefreshAutoStateFooter.swift
//  AIRun
//
//  Created by AIRun on 20248/14.
//

import UIKit
import NVActivityIndicatorView

class RefreshAutoStateFooter: MJRefreshAutoStateFooter {

    // MARK: - 属性声明

    override func prepare() {
        super.prepare()
        self.addSubview(self.indicatorView)
        self.triggerAutomaticallyRefreshPercent = -1
    }
    override func placeSubviews() {
        super.placeSubviews()
    }
    
    override var state: MJRefreshState {
        didSet {
            if state == .idle {
                indicatorView.stopAnimating()
            }else if state == .noMoreData {
                self.stateLabel?.isHidden = false
                self.stateLabel?.text = ""
                indicatorView.stopAnimating()
            
            }else{
                self.stateLabel?.isHidden = true
                indicatorView.startAnimating()
            }
        }
    }
    lazy var indicatorView: NVActivityIndicatorView = {
        let v = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: 50), type: .ballPulse, color: UIColor.appPinkColor(), padding: 10)
        return v
    }()
}



