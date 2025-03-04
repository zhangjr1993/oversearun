//
//  BaseTableView.swift
//  AIRun
//
//  Created by AIRun on 20247/10.
//

import UIKit

enum BaseTableViewEmptyType {
    /// ai列表
    case defaultType
    /// user列表
    case userList
}

class BaseTableView: UITableView {
    
    public var emptyType: BaseTableEmptyView? {
        didSet {
            
        }
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.backgroundColor = UIColor.clear
        self.separatorColor = .clear
        self.separatorStyle = .none
        self.estimatedSectionFooterHeight = 0
        self.estimatedSectionHeaderHeight = 0
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.sectionHeaderTopPadding = 0
        self.contentInsetAdjustmentBehavior = .never
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func emptyBackgroundView(type: BaseTableViewEmptyType = .defaultType) -> BaseTableEmptyView {
        return BaseTableEmptyView(frame: UIScreen.main.bounds, emptyType: type)
    }
    
    static func emptyTableFooterView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: UIScreen.safeAreaInsets.bottom))
        return view
    }
    
}

extension UIScrollView {
    func addMJRefreshHeader(_ refreshBlock: @escaping () -> Void) {
        self.mj_header = RefreshStateHeader(refreshingBlock: refreshBlock)
    }
    
    func addMJAutoFooter(_ loadMoreBlock: @escaping () -> Void) {
        self.mj_footer = RefreshAutoStateFooter(refreshingBlock: loadMoreBlock)
    }
    
    func addMJBackStateFooter(_ loadMoreBlock: @escaping () -> Void) {
        self.mj_footer = RefreshBackStateFooter(refreshingBlock: loadMoreBlock)

    }
    
    func endRefresh() {
        self.mj_header?.endRefreshing()
        self.mj_footer?.endRefreshing()
    }
    
    func removeHeaderRefresh() {
        
        self.mj_header?.removeFromSuperview()
        self.mj_header = nil
    }
    
    func endLoadMoreData(count: Int) {
        if count > 0 {
            self.mj_footer?.endRefreshing()
        }else {
            self.mj_footer?.state = .noMoreData
        }
    }
    
    func endNextLoadMoreData(next: Bool) {
        if next {
            self.mj_footer?.endRefreshing()
        }else {
            self.mj_footer?.state = .noMoreData
        }
    }
}

class BaseTableEmptyView: UIView {
        
    public init(frame: CGRect, emptyType: BaseTableViewEmptyType) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.appBgColor()
        
        self.addSubview(emptyIcon)
        self.addSubview(emptyTitleLab)
        self.addSubview(reloadBtn)
        
        emptyIcon.snp.makeConstraints { make in
            make.top.equalTo(125)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 133, height: 133))
        }
        emptyTitleLab.snp.makeConstraints { make in
            make.top.equalTo(emptyIcon.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        reloadBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyTitleLab.snp.bottom).offset(10)
            make.size.equalTo(CGSize(width: 205, height: 48))
        }
        
        configData(type: emptyType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var emptyIcon: UIImageView = {
        let img = UIImageView()
        img.image = UIImage.imgNamed(name: "icon_empty")
        return img
    }()
    
    lazy var emptyTitleLab: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.font = .regularFont(size: 15)
        lab.textColor = UIColor.whiteColor(alpha: 0.38)
        lab.textAlignment = .center
        return lab
    }()
    
    lazy var reloadBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.isHidden = true
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = .mediumFont(size: 16)
        btn.setTitle("Refresh", for: .normal)
        let bg = UIImage.createGradientImg(colors: UIColor.appGradientColor(), size: CGSize(width: 205, height: 48)).isRoundCorner()
        btn.setBackgroundImage(bg, for: .normal)
        return btn
    }()
}

extension BaseTableEmptyView {
    private func configData(type: BaseTableViewEmptyType) {
        self.backgroundColor = .clear

        switch type {
        case .userList:
            emptyTitleLab.text = "No user yet"
        default:
            emptyTitleLab.text = "No character yet"
            break
        }
    }
}

class BaseCollectionFooterView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
