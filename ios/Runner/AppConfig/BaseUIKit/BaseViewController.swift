//
//  BaseViewController.swift
//  AIRun
//
//  Created by AIRun on 20247/7.
//

import UIKit

class BaseViewController: UIViewController {
    
    var hideNaviBar = false          // 是否隐藏导航
    let bag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .appBgColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(hideNaviBar, animated: true)
    }
    
    override func loadView() {
        super.loadView()
    }
    
    deinit {
        printLog(message: "🌛 🌛 deinit \(self)")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension UIViewController {
    func naviPopbackItem() -> UIBarButtonItem {
        let item = UIBarButtonItem.init(image: UIImage.imgNamed(name: "btn_back_White"), style: .plain, target: self, action: #selector(naviPopback))
        item.width = 34
        return item
    }
    // 设置返回按钮
    func naviBackButton(imgName: String = "btn_back_White") -> UIButton {
        let item = UIButton(type: .custom)
        item.setImage(UIImage.imgNamed(name: imgName), for: .normal)
        item.addTarget(self, action: #selector(naviPopback), for: .touchUpInside)
        item.frame = CGRect(x: 11, y: UIScreen.statusBarHeight, width: 34, height: UIScreen.navigationBarHeight)
        return item
    }
    
    @objc func naviPopback() {
        navigationController?.popViewController(animated: true)
    }
}

extension BaseViewController {
    func popToTagretVC(className: String) {
        if let viewControllers = self.navigationController?.viewControllers {
            var targetVC: UIViewController?
            for vc in viewControllers {
                if vc.className().contains(className) {
                    targetVC = vc
                    break
                }
            }
            
            guard let targetVC else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            self.navigationController?.popToViewController(targetVC, animated: true)
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}
