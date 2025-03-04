//
//  MineMainController.swift
//  AIRun
//
//  Created by AIRun on 2025/1/16.
//

import UIKit
import NVActivityIndicatorView

class MineMainController: BaseViewController {
    
    enum RefreshState {
        case idle           // 闲置状态
        case pulling       // 下拉中但未达到刷新阈值
        case willRefresh   // 达到刷新阈值
        case refreshing    // 刷新中
    }
    
    private var refreshState: RefreshState = .idle {
        didSet {
            switch refreshState {
            case .idle:
                indicatorView.stopAnimating()
            case .pulling:
                indicatorView.stopAnimating()
            case .willRefresh:
                indicatorView.startAnimating()
            case .refreshing:
                indicatorView.startAnimating()
            }
        }
    }
    
    let refreshThreshold: CGFloat = -50.0
    let titles = ["My Following", "My Block"]
    private var isNeedRefresh = false

    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        createUILimit()
        addEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshMyInfo()
    }
   
    private lazy var userInfoView = MineUserHomeView().then {
        $0.backgroundColor = .clear
    }
   
    private lazy var pagingView: JXPagingView = {
        let v = JXPagingView(delegate: self)
        v.backgroundColor = .clear
        v.mainTableView.backgroundColor = .clear
        v.pinSectionHeaderVerticalOffset = Int(UIScreen.statusBarHeight)
        return v
    }()
    
    private lazy var segmentView = JXSegmentedView().then {
        let indicator = JXSegmentedIndicatorGradientLineView()
        indicator.indicatorHeight = 2
        indicator.indicatorWidth = 24
        indicator.indicatorCornerRadius = 1
        indicator.verticalOffset = 8
        indicator.colors = UIColor.lineGradientColors()

        $0.indicators = [indicator]
        $0.dataSource = segmentedDataSource
        $0.backgroundColor = .clear
    }
    
    private lazy var segmentedDataSource: JXSegmentedTitleDataSource = {
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.titles = self.titles
        dataSource.isTitleZoomEnabled = false
        dataSource.titleSelectedFont = UIFont.boldFont(size: 16)
        dataSource.titleNormalFont = UIFont.regularFont(size: 16)
        dataSource.titleSelectedColor = UIColor.white
        dataSource.titleNormalColor = UIColor.whiteColor(alpha: 0.38)
        dataSource.itemSpacing = 32
        dataSource.isItemSpacingAverageEnabled = true
        return dataSource
    }()
    
    private lazy var indicatorView: NVActivityIndicatorView = {
        let v = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: 50), type: .ballClipRotatePulse, color: UIColor.appPinkColor(), padding: 10)
        v.stopAnimating()
        return v
    }()
    
    private lazy var segBgView = UIView().then {
        $0.backgroundColor = .clear
    }
}

extension MineMainController {
    private func openSettingController() {
        let vc = SettingController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openVipMemberController() {
        APPPushManager.default.pushToWebView(webType: .vip)
    }
    
    private func showUserEditPopView() {
        let alert = MineUserEditPopView()
        alert.show()
    }
}

extension MineMainController{
    /// 添加UI
    func createUI() {
        self.hideNaviBar = true
        segBgView.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.screenWidth, height: 60))
        segBgView.addSubview(segmentView)
        segmentView.frame = CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: 26+24)
        userInfoView.frame = CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: CGFloat(userInfoView.reloadHeight))
        
        view.addSubview(pagingView)
        view.addSubview(indicatorView)
        pagingView.listContainerView.backgroundColor = .clear
        segmentView.listContainer = pagingView.listContainerView as? any JXSegmentedViewListContainer
    }
    /// 设置约束
    func createUILimit(){
        pagingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    ///
    func addEvent() {
        userInfoView.userHomeViewHandle = { [weak self] index in
            guard let `self` = self else { return }
            if index == 1 {
                self.showUserEditPopView()
            }else if index == 2 {
                self.openSettingController()
            }else {
                self.openVipMemberController()
            }
        }
        
        NotificationCenter.default.rx.notification(.needRefreshMyInfo).subscribe(onNext: { [weak self] noti in
            guard let `self` = self else { return }
            self.refreshMyInfo()
        }).disposed(by: bag)
    }
    
    private func refreshMyInfo() {
        AppLoginManager.default.getmyInfoReq { [weak self] in
            guard let `self` = self else { return }
            self.userInfoView.reloadUserInfo()
            guard self.isNeedRefresh else { return }
            // 下拉刷新才调用
            self.isNeedRefresh = false
            self.pagingView.reloadData()
        }
    }
}

extension MineMainController: JXPagingViewDelegate {
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        return userInfoView.reloadHeight
    }

    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return userInfoView
    }

    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return 50+10
    }

    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        return segBgView
    }

    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return titles.count
    }

    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
       
        if index == 0 {
            let vc = MineFollowingListController()
            return vc
            
        }else {
            let vc = MineBlockListController()
            return vc
        }
        
    }

    func mainTableViewDidScroll(_ scrollView: UIScrollView) {
        let offY = scrollView.contentOffset.y + 3
        let height = CGFloat(userInfoView.reloadHeight) - UIScreen.statusBarHeight
        userInfoView.alpha = (height - offY) / height
        
        // Update indicator position based on scroll offset
        indicatorView.frame.origin.y = max(0, -offY - indicatorView.frame.height) + UIScreen.statusBarHeight
        
        // Handle refresh states during scrolling
        if refreshState != .refreshing {
            if offY < refreshThreshold {
                refreshState = .willRefresh
            } else {
                refreshState = .pulling
            }
        }
    }
   
    func pagingView(_ pagingView: JXPagingView, mainTableViewWillBeginDragging scrollView: UIScrollView) {
        if refreshState == .refreshing { return }
        refreshState = .pulling
    }
    
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidEndDragging scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshState == .refreshing { return }
        
        let offY = scrollView.contentOffset.y + 3
        if offY < refreshThreshold {
            refreshState = .refreshing
            // Start refresh
            self.isNeedRefresh = true
            self.refreshMyInfo()
            
            // Simulate network delay and reset state
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self = self else { return }
                self.refreshState = .idle
            }
        } else {
            refreshState = .idle
        }
    }

}
