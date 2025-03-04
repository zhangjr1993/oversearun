//
//  HomeMainController.swift
//  AIRun
//
//  Created by AIRun on 2025/1/16.
//

import UIKit

class HomeMainController: BaseViewController {
    
    private var tabs: [HomeTabListModel] = []
    private var tags: [HomeTagListModel] = []
    private var filterSex: UserSexType = .unowned
    /// 标记刷新 拉黑/取消拉黑 用户、AI
    private var markRefresh = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createUI()
        self.createUILimit()
        self.addEvent()
        self.showData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if markRefresh {
            markRefresh = false
            self.segmentView.reloadData()
        }
    }
    
    private lazy var topView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var filterBtn = LayoutButton().then {
        $0.backgroundColor = UIColor.init(hexStr: "#FF9E48")
        $0.layer.cornerRadius = 13
        $0.layer.masksToBounds = true
        $0.imageSize = CGSize(width: 22, height: 22)
        $0.midSpacing = 0
        $0.titleLabel?.font = .regularFont(size: 15)
        $0.setImage(UIImage.imgNamed(name: "icon_create_non"), for: .normal)
        $0.setTitle("All", for: .normal)
    }

    private lazy var searchBtn = UIButton().then {
        $0.setImage(UIImage.imgNamed(name: "icon_home_search"), for: .normal)
    }
    
    private lazy var titleLab = UILabel().then {
        $0.text = "Characters"
        $0.font = .mediumFont(size: 17)
        $0.textColor = .white
    }
    
    private lazy var segmentView = JXSegmentedView().then {
        let indicator = JXSegmentedIndicatorGradientLineView()
        indicator.indicatorHeight = 2
        indicator.indicatorWidth = 24
        indicator.indicatorCornerRadius = 1
        indicator.verticalOffset = 8
        indicator.colors = UIColor.lineGradientColors()

        $0.contentEdgeInsetLeft = 4
        $0.contentEdgeInsetRight = 0
        $0.indicators = [indicator]
        $0.delegate = self
        $0.dataSource = segmentedDataSource
    }
    
    private lazy var segmentedDataSource: JXSegmentedTitleDataSource = {
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.isTitleColorGradientEnabled = true
        dataSource.titles = self.getTitlesArray()
        dataSource.isTitleZoomEnabled = false
        dataSource.titleSelectedFont = UIFont.boldFont(size: 16)
        dataSource.titleNormalFont = UIFont.regularFont(size: 16)
        dataSource.titleSelectedColor = UIColor.white
        dataSource.titleNormalColor = UIColor.whiteColor(alpha: 0.38)
        dataSource.itemSpacing = 16
        dataSource.isItemSpacingAverageEnabled = false
        return dataSource
    }()
    
    private lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    
    private lazy var labelView = HomeLabelOptionView().then {
        $0.backgroundColor = .clear
    }
}

extension HomeMainController {
    private func getTitlesArray() -> [String] {
        return tabs.map { $0.tabName }
    }
    
    private func createUI() {
        self.hideNaviBar = true
        
        self.tabs = APPManager.default.config.tabs
        self.tags = APPManager.default.config.tagList
        if self.tabs.count == 0 {
            let model = HomeTabListModel(tab: 1, tabName: "Recent Hits")
            self.tabs = [model]
        }

        view.addSubview(topView)
        topView.addSubview(filterBtn)
        topView.addSubview(titleLab)
        topView.addSubview(searchBtn)
        topView.addSubview(segmentView)
        topView.addSubview(labelView)
        view.addSubview(listContainerView)
        segmentView.listContainer = listContainerView
    }
    
    private func createUILimit() {
        topView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(138+UIScreen.statusBarHeight)
        }
        
        filterBtn.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.top.equalTo(UIScreen.statusBarHeight+8)
            make.height.equalTo(26)
            make.width.equalTo(52)
        }
        
        titleLab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(filterBtn)
        }
        
        searchBtn.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.top.equalTo(UIScreen.statusBarHeight+8)
            make.width.height.equalTo(26)
        }
        
        segmentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(UIScreen.statusBarHeight+42)
            make.height.equalTo(48)
        }
        
        labelView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(segmentView.snp.bottom).offset(6)
            make.height.equalTo(26)
        }
        
        listContainerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
        }
    }
    
    private func addEvent() {
        filterBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.showFilterSexPopView()
        }).disposed(by: bag)
        
        searchBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            let vc = HomeSearchController()
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: bag)
        
        labelView.labsFilterHandle = { [weak self] in
            guard let `self` = self else { return }
            self.updateListContainerWithChangeFilter()
        }
        
        labelView.pullBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.showFullTagsPopView()
        }).disposed(by: bag)
        
        /// 用户拉黑
        NotificationCenter.default.rx.notification(.userBlockedUpdated).subscribe(onNext: { [weak self] noti in
            guard let `self` = self else { return }
            guard let obj = noti.object as? [String: Any], let mid = obj["mid"] as? Int else { return }
            self.markRefresh = true
        }).disposed(by: bag)
        
        /// 过滤开关
        NotificationCenter.default.rx.notification(.userFilterUpdate).subscribe(onNext: { [weak self] noti in
            guard let `self` = self else { return }
            self.markRefresh = true
        }).disposed(by: bag)
        
        NotificationCenter.default.rx.notification(.appConfigTabsUpdate).subscribe(onNext: { [weak self] noti in
            guard let `self` = self else { return }
            // 1. 更新数据源
            self.tabs = APPManager.default.config.tabs
            self.segmentedDataSource.titles = self.getTitlesArray()
            // 2. 刷新数据源
            self.segmentedDataSource.reloadData(selectedIndex: 0)
            // 3. 刷新视图
            self.segmentView.reloadData()
            
        }).disposed(by: bag)
        
        NotificationCenter.default.rx.notification(.appConfigTagsUpdate).subscribe(onNext: { [weak self] noti in
            guard let `self` = self else { return }
            self.tags = APPManager.default.config.tagList
            self.showData()
        }).disposed(by: bag)

    }
    
    private func showData() {
        labelView.showData(self.tags)
    }
    
    /// 改变筛选条件同步当前segmentView.selectedIndex
    private func updateListContainerWithChangeFilter() {
        guard let vc = self.listContainerView.validListDict[self.segmentView.selectedIndex] as? HomeListContainerController else {
            return
        }
        vc.synchronizeFilterTags()
    }
}

extension HomeMainController {
    private func showFilterSexPopView() {
        let view = HomeFilterSexPopView()
        view.updateSelectedSex(self.filterSex)
        view.show()
        view.filterSexResultHandle = { [weak self] result in
            guard let `self` = self else { return }
            self.updateHomeSelectedSex(result)
        }
    }
    
    private func showFullTagsPopView() {
        
        let pop = HomeLabelListPopView(self.tags)
        pop.show()
        pop.popFilterTagsHandle = { [weak self] result in
            guard let `self` = self else { return }
            AppCacheManager.default.homeFilter.selectedTags = result
            self.labelView.popFilterUpdateSource()
            self.updateListContainerWithChangeFilter()
        }
    }
    
    private func updateHomeSelectedSex(_ sex: UserSexType) {
        self.filterSex = sex
        AppCacheManager.default.homeFilter.sex = sex
        self.updateListContainerWithChangeFilter()
        
        let width: CGFloat
        switch sex {
        case .unowned:
            width = 52
            filterBtn.backgroundColor = UIColor.init(hexStr: "#FF9E48")
            filterBtn.setTitle("All", for: .normal)
            filterBtn.setImage(UIImage.imgNamed(name: "icon_create_non"), for: .normal)
        case .boy:
            width = 68
            filterBtn.backgroundColor = UIColor.init(hexStr: "#8898FF")
            filterBtn.setTitle("Male", for: .normal)
            filterBtn.setImage(UIImage.imgNamed(name: "icon_create_male"), for: .normal)
        case .girl:
            width = 88
            filterBtn.backgroundColor = UIColor.init(hexStr: "#FF7BD3")
            filterBtn.setTitle("Female", for: .normal)
            filterBtn.setImage(UIImage.imgNamed(name: "icon_create_female"), for: .normal)
        case .quadratic:
            width = 124
            filterBtn.backgroundColor = UIColor.init(hexStr: "#FF9E48")
            filterBtn.setTitle("Non-binary", for: .normal)
            filterBtn.setImage(UIImage.imgNamed(name: "icon_create_non"), for: .normal)
        }
        
        filterBtn.snp.updateConstraints { make in
            make.width.equalTo(width)
        }
    }
}

extension HomeMainController: JXSegmentedViewDelegate, JXSegmentedListContainerViewDataSource {
    
    /// 滑动或者点击都回调
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if let vc = self.listContainerView.validListDict[index] as? HomeListContainerController {
            vc.synchronizeFilterTags()
        }
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        
    }
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        
        let tabM = self.tabs[index]
        let sex = AppCacheManager.default.homeFilter.sex
        let tags = AppCacheManager.default.homeFilter.selectedTags
        let vc = HomeListContainerController(tabModel: tabM, sex: sex, tags: tags)
        return vc
    }
    
}
