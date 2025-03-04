//
//  BaseNavigationController.swift
//  AIRun
//
//  Created by AIRun on 20247/11.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    public var tabBarItemType: TabBarItemType = .home
    var pushing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
        self.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var debugDescription: String {
        return "\(self):\(type(of: self))\n\(viewControllers)"
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        guard pushing == false else { return }
        pushing = true
        if (tabBarController?.presentationController) != nil {
            tabBarController?.presentedViewController?.dismiss(animated: false, completion: nil)
        }
        if viewControllers.count >= 1 {
            if viewController.navigationItem.leftBarButtonItem == nil {
                viewController.navigationItem.leftBarButtonItem = viewController.naviPopbackItem()
            }
        }
        if(viewControllers.count != 0) {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }

    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {

        super.setViewControllers(viewControllers, animated: animated)
    }
 
    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        // 解决iOS 14 popToRootViewController tabbar会隐藏的问题
        if animated {
            self.viewControllers.last?.hidesBottomBarWhenPushed = false
        }
        return super.popToRootViewController(animated: animated)
    }
    

}

extension BaseNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController.hidesBottomBarWhenPushed {
            self.tabBarController?.tabBar.isHidden = true
        }else {
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        pushing = false
    }
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if children.count == 1 {
            return false
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }
    
}
