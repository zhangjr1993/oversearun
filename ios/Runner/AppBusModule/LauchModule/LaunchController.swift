//
//  LauchViewController.swift
//  AIRun
//
//  Created by AIRun on 2025/1/16.
//

import UIKit

class LaunchController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    lazy var bgView: UIImageView = {
        let bg = UIImageView()
        bg.image = UIImage.imgNamed(name: "img_sp")
        bg.contentMode = .scaleAspectFill
        return bg
    }()
    

   

}
