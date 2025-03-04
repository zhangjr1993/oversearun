//
//  BaseTabBar.swift
//  AIRun
//
//  Created by AIRun on 20247/12.
//

import UIKit

enum TabBarItemType: Int {
    case home = 0
    case create = 1
    case message = 2
    case mine = 3
}


class BaseTabBar: UITabBar {
    
    private var currentItemType: TabBarItemType = .home

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }    
}

extension BaseTabBar {
    public func setupTabBarItems(_ items: [TabBarItemType]) {
        guard items.count > 0 else {return}
        let margin = 10.0
        let width = (UIScreen.screenWidth - margin) / CGFloat(items.count)

        for (index, type) in items.enumerated() {
            let rect = CGRect(x: 5 + CGFloat(index)*width, y: 6, width: width, height: UIScreen.tabBarHeight)
            let button = CusTabBarButton.init(frame: rect, itemType: type)
            button.tag = 100 + type.rawValue
            button.custom_didSelected(false)
            addSubview(button)
        }
    }
    
    public func setDidSelectedItem(itemType: TabBarItemType) {
        
        if let btn = viewWithTag(100 + currentItemType.rawValue) as? CusTabBarButton, itemType != currentItemType, btn.isSelected == true {
            btn.custom_didSelected(false)
        }
        
        if let newBtn = viewWithTag(100 + itemType.rawValue) as? CusTabBarButton {
            newBtn.custom_didSelected(true)
            currentItemType = itemType
        }
        
    }
    
    func refreshBadgeLable(unread: Int, barType: TabBarItemType) {
        if let btn = self.viewWithTag(barType.rawValue + 100) as? CusTabBarButton {
            btn.showBadgeNum(num: unread)
        }
    }
}

/// MARK：--------------------------------------------------------------
class CusTabBarButton: UIButton {
    
    public var btnType: TabBarItemType = .home
    
    init(frame: CGRect, itemType: TabBarItemType) {
        super.init(frame: frame)
        setupUI(itemType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let iconImg = UIImageView()

    lazy var desLab: UILabel = {
        let lab = UILabel()
        lab.font = .boldFont(size: 11)
        lab.textAlignment = .center
        return lab
    }()
   
    /// 红点
    lazy var badgeLabel: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = .appRedColor()
        lab.textColor = .white
        lab.textAlignment = .center
        lab.layer.masksToBounds = true
        lab.layer.cornerRadius = 9
        lab.layer.borderColor = UIColor.white.cgColor
        lab.layer.borderWidth = 1
        lab.isHidden = true
        lab.tag = 1000
        return lab
    }()
    
}

extension CusTabBarButton {
    private func setupUI(_ type: TabBarItemType) {
        self.btnType = type
        
        addSubview(iconImg)
        addSubview(badgeLabel)
        
        iconImg.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(12)
            make.width.height.equalTo(25)
        }
        
        badgeLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImg.snp.top).offset(-4)
            make.leading.equalTo(iconImg.snp.leading).offset(14)
            make.height.equalTo(18)
            make.width.equalTo(18)
        }
    }
}

extension CusTabBarButton {
    
    public func custom_didSelected(_ status: Bool) {
        self.isSelected = status
        iconImg.image = status ? selectedImage(btnType) : normalImage(btnType)
    }
    
    public func showBadgeNum(num: Int) {
        badgeLabel.isHidden = num == 0
        badgeLabel.text = num > 99 ? "99+" : "\(num)"
        let fitSize = badgeLabel.sizeThatFits(CGSize(width: CGFloat(MAXFLOAT), height: 18))
        badgeLabel.snp.updateConstraints { make in
            make.width.equalTo(max(18, fitSize.width + 10))
        }
    }
}

extension CusTabBarButton {
    
     private func normalImage(_ itemType: TabBarItemType) -> UIImage {
         switch itemType {
         case .home:
             return UIImage.imgNamed(name: "btn_tab_home_nor")
         case .create:
             return UIImage.imgNamed(name: "btn_tab_create_nor")
         case .message:
             return UIImage.imgNamed(name: "btn_tab_chat_nor")
         case .mine:
             return UIImage.imgNamed(name: "btn_tab_me_nor")
         default:
             return UIImage()
         }
     }
     
     private func selectedImage(_ itemType: TabBarItemType) -> UIImage {
         switch itemType {
         case .home:
             return UIImage.imgNamed(name: "btn_tab_home_pre")
         case .create:
             return UIImage.imgNamed(name: "btn_tab_create_pre")
         case .message:
             return UIImage.imgNamed(name: "btn_tab_chat_pre")
         case .mine:
             return UIImage.imgNamed(name: "btn_tab_me_pre")
         default:
             return UIImage()
         }
     }
}
