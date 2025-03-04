//
//  MineBlockListController.swift
//  AIRun
//
//  Created by Bolo on 2025/2/6.
//

import UIKit

class MineBlockListController: BaseViewController {

    var listViewDidScrollCallback: ((UIScrollView) -> ())?
    
    private var dataArray: [HomeCommonListModel] = []
    private var page = 1
    private let titles = ["Characters", "Users"]
    
    deinit {
        listViewDidScrollCallback = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.createUI()
        self.createUILimit()
        self.addEvent()
    }
    
    private lazy var topView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var segmentedView = JXSegmentedView().then {
        let indicator = JXSegmentedIndicatorBaseView()
        indicator.indicatorHeight = 26
        indicator.indicatorWidth = JXSegmentedViewAutomaticDimension
        indicator.isIndicatorWidthSameAsItemContent = true
        indicator.indicatorColor = UIColor.init(hexStr: "#FFDBE6")
        indicator.indicatorWidthIncrement = 12

//        $0.contentEdgeInsetLeft = 4
//        $0.contentEdgeInsetRight = 0
        $0.indicators = [indicator]
        $0.delegate = self
        $0.dataSource = segmentedDataSource
    }
    
    private lazy var segmentedDataSource: MineBlockListDataSource = {
        let dataSource = MineBlockListDataSource()
        dataSource.titles = self.titles
        dataSource.isTitleZoomEnabled = false
        dataSource.titleSelectedFont = UIFont.mediumFont(size: 15)
        dataSource.titleNormalFont = UIFont.mediumFont(size: 15)
        dataSource.titleSelectedColor = UIColor.appBrownColor()
        dataSource.titleNormalColor = UIColor.whiteColor(alpha: 0.38)
        dataSource.itemSpacing = 8
        dataSource.isItemSpacingAverageEnabled = false
        dataSource.normalImage = UIImage.createColorImg(color: UIColor.whiteColor(alpha: 0.05))
        dataSource.selectedImage = UIImage.createColorImg(color: UIColor.init(hexStr: "#FFDBE6"))
        
        return dataSource
    }()
    
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    
}

extension MineBlockListController {
    
}

extension MineBlockListController {
    private func createUI() {
        self.hideNaviBar = true
        view.addSubview(topView)
        topView.addSubview(segmentedView)
        view.addSubview(listContainerView)
        segmentedView.listContainer = listContainerView
    }
    
    private func createUILimit() {
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(26+12)
        }
        segmentedView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.size.equalTo(CGSize(width: 178+16, height: 26))
        }
        listContainerView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func addEvent() {
        
    }
}

extension MineBlockListController: JXSegmentedViewDelegate, JXSegmentedListContainerViewDataSource {
    /// 滑动或者点击都回调
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        
    }
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        
        let listView = MineBlockListContainerView(frame: UIScreen.main.bounds, type: index+1)
        listView.listViewDidScrollCallback = listViewDidScrollCallback
        return listView
    }
    
}

extension MineBlockListController: JXPagingViewListViewDelegate {
    public func listView() -> UIView {
        return self.view
    }
    
    public func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.listViewDidScrollCallback = callback
    }

    public func listScrollView() -> UIScrollView {
        return self.listContainerView.scrollView
    }
}
