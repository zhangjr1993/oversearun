//
//  ALRootTabBarController.swift
//  AIRun
//
//  Created by AIRun on 20247/11.
//

import UIKit

enum ALRootType {
    case unknown
    case login
    case inApp
}

class BaseTabBarController: UITabBarController {

    let bag: DisposeBag = DisposeBag()
    private var rootType: ALRootType = .unknown
    private var tabBarView: BaseTabBar?
    private var lastSelectedIndex: TabBarItemType = .home {
        didSet {
            lastSeletedSubject.accept(lastSelectedIndex)
        }
    }
    var lastSeletedSubject: PublishRelay<TabBarItemType> = PublishRelay.init()

    private lazy var appRootViewControllers: [BaseNavigationController] = {
        var tempArr: [BaseNavigationController] = []
        
        let nav0 = BaseNavigationController.init(rootViewController: HomeMainController())
        nav0.tabBarItemType = .home
        
        let nav1 = BaseNavigationController.init(rootViewController: CreateMainController())
        nav1.tabBarItemType = .create
        
        let nav2 = BaseNavigationController.init(rootViewController: ChatMainController())
        nav2.tabBarItemType = .message
        
        let nav3 = BaseNavigationController.init(rootViewController: MineMainController())
        nav3.tabBarItemType = .mine
        
        tempArr.append(contentsOf: [nav0, nav1, nav2, nav3])
        return tempArr
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        view.backgroundColor = .appBgColor()
        viewControllers = self.appRootViewControllers
        setupTabBar()
        selectTabbar(type: .home)
        addObserver()
        if APPManager.default.isHasLogin(needJump: false) {
            APPManager.default.loginSuccessHandle()
        }
    }
    // MARK: - 点击
    override var selectedViewController: UIViewController? {
        didSet {
            if selectedIndex == NSNotFound {
                return
            }
            if let nav = selectedViewController as? BaseNavigationController, let topVC: UIViewController = nav.topViewController {
                                
                tabBarView?.setDidSelectedItem(itemType: nav.tabBarItemType)
                lastSelectedIndex = nav.tabBarItemType
                super.selectedViewController = selectedViewController
            }
                  
        }
    }
    
    func getLastSelectedViewController() -> BaseNavigationController? {
                
        return self.appRootViewControllers.first(where: { $0.tabBarItemType == self.lastSelectedIndex })
    }

}

extension BaseTabBarController {

    private func setupTabBar() {
        let tabBarView = BaseTabBar()
        self.tabBarView = tabBarView
        tabBarView.frame = CGRect(x: 0, y: UIScreen.screenHeight-UIScreen.tabBarHeight, width: UIScreen.screenWidth, height: UIScreen.tabBarHeight)
        tabBarView.backgroundColor = UIColor.init(hexStr: "#242325")

        let backgroundImage = UIImage.createColorImg(color: UIColor.init(hexStr: "#242325"))
        tabBarView.backgroundImage = backgroundImage
        tabBarView.shadowImage = UIImage()
        
        let appearance = UITabBarAppearance()
        appearance.shadowColor = UIColor.clear
        appearance.shadowImage = nil
        appearance.backgroundImage = backgroundImage
        appearance.backgroundEffect = nil
        tabBarView.standardAppearance = appearance
        
        
        setValue(tabBarView, forKey: "tabBar")
        var barItems: [TabBarItemType] = []
        appRootViewControllers.forEach { temp in
            barItems.append(temp.tabBarItemType)
        }
        tabBarView.setupTabBarItems(barItems)
    }
    
    func selectTabbar(type: TabBarItemType) {
        guard type.rawValue < self.viewControllers?.count ?? 0 else { return }
        let vc = self.viewControllers?[type.rawValue]
        self.selectedIndex = type.rawValue
        self.selectedViewController = vc
    }

}

extension BaseTabBarController: IMManagerDelegate{
    private func addObserver() {
        APPIMManager.share.addIMDelegate(self)
    }
    func onUnreadMsgCountChanged(count: Int) {
        print("IM未读数 - \(count)")
        APPLogManager.default.writeLog(logStr: "IM未读总数回调: \(count)")
        APPIMManager.share.unreadMsgNum = count
        UIApplication.shared.applicationIconBadgeNumber = count
        tabBarView?.refreshBadgeLable(unread: count, barType: .message)
    }
}

extension BaseTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if let nav = viewController as? BaseNavigationController, [.home, .create].contains(nav.tabBarItemType) {
            return true
        }
        return APPManager.default.isHasLogin()
    }
}
