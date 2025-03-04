//
//  RefreshBackStateFooter.swift
//  AIRun
//
//  Created by AIRun on 20248/14.
//

import UIKit
import NVActivityIndicatorView

class RefreshBackStateFooter: MJRefreshBackStateFooter {

    override func prepare() {
        super.prepare()
        self.stateLabel?.isHidden = true
        self.addSubview(self.indicatorView)
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
                self.indicatorView.stopAnimating()
            
            }else{
                self.stateLabel?.isHidden = true
                self.indicatorView.startAnimating()
            }
        }
    }
    
    lazy var indicatorView: NVActivityIndicatorView = {
        let v = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: 50), type: .ballPulse, color: UIColor.appPinkColor(), padding: 10)
        return v
    }()
}
