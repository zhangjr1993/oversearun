//
//  AIEditMainController.swift
//  AIRun
//
//  Created by Bolo on 2025/2/7.
//

import UIKit

// MARK: - 创建_编辑共用
class AIEditMainController: BaseViewController {
    /// AI被删除了
    public var deleteAIHandle: ((Int) -> Void)?
    /// 创建成功进入私信
    public var createNewSuccessHandle: ((Int) -> Void)?
    /// 编辑成功刷新
    public var modifySuccessHandle: ((AIEditingMainModel, Int?) -> Void)?
    /// 有mid就是编辑
    private var mid: Int?
    ///
    var dataArray: [AIEditSectionType] = []
    /// 区分picker操作
    private var pickerAction: AIEditSectionType?
    /// 编辑记录model
    private var dataModel = AIEditingMainModel()
    /// 编辑入口-对照修改
    private var editingModel = AIEditingMainModel()
    /// 待上传的图片
    private var waitModelArray: [AIEditingGalleryModel] = []
    /// 文本检测非法
    private var illegalType: [Int] = []
    /// 文本检测 false未检or失败，true检测过
    private var contentIllegal = false
    
    init(mid: Int?) {
        super.init(nibName: nil, bundle: nil)
        self.mid = mid
        self.createBtn.setTitle(mid != nil ? "Save" : "Create Character", for: .normal)
        self.dataArray = mid != nil ? AIEditSectionType.allCases.filter({ $0 != .rating }) : AIEditSectionType.allCases
    }
    
    /// 文件上传
    init(upload editModel: AIEditingMainModel) {
        super.init(nibName: nil, bundle: nil)
        self.dataModel = editModel
        self.createBtn.setTitle("Create Character", for: .normal)
        self.dataArray = AIEditSectionType.allCases
        // 头像是否要裁剪？
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.createUI()
        self.createUILimit()
        self.addEvent()
        self.getEditInfoReq()
    }
    
    override func naviPopback() {
        self.showNaviBackPopView()
    }
    
    private lazy var tableView = BaseTableView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.tableFooterView = self.tableFooterView
        $0.register(AIEditMainAvatarCell.self, forCellReuseIdentifier: AIEditMainAvatarCell.description())
        $0.register(AIEditMainNickCell.self, forCellReuseIdentifier: AIEditMainNickCell.description())
        $0.register(AIEditMainButtonCell.self, forCellReuseIdentifier: AIEditMainButtonCell.description())
        $0.register(AIEditMainTagsCell.self, forCellReuseIdentifier: AIEditMainTagsCell.description())
        $0.register(AIEditMainTextViewCell.self, forCellReuseIdentifier: AIEditMainTextViewCell.description())
        $0.register(AIEditMainGreetingCell.self, forCellReuseIdentifier: AIEditMainGreetingCell.description())
        $0.register(AIEditMainGalleryCell.self, forCellReuseIdentifier: AIEditMainGalleryCell.description())
    }
   
    private lazy var tableFooterView = AIEditMainTableFooterView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.screenWidth, height: 88+48+UIScreen.safeAreaInsets.bottom))).then {
        $0.backgroundColor = .clear
    }

    private lazy var createBtn = UIButton().then {
        $0.backgroundColor = UIColor.init(hexStr: "#282828")
        let gray = UIImage.createButtonImage(type: .lightGray, size: CGSize(width: UIScreen.screenWidth-96, height: 48), isCorner: 24)
        let normal = UIImage.createButtonImage(type: .normal, size: CGSize(width: UIScreen.screenWidth-96, height: 48), isCorner: 24)
        $0.setBackgroundImage(normal, for: .normal)
        $0.setBackgroundImage(gray, for: .disabled)
        $0.setTitleColor(UIColor.appBrownColor(), for: .normal)
        $0.setTitleColor(UIColor.whiteColor(alpha: 0.2), for: .disabled)
        $0.isEnabled = false
        $0.layer.cornerRadius = 24
        $0.layer.masksToBounds = true
    }
    
}

extension AIEditMainController {
    /// 编辑AI
    private func getEditInfoReq() {
        guard let mid else { return }
        
        AppRequest(CreateModuleApi.editAIInfo(params: ["mid": mid]), modelType: AIEditMainInfoModel.self) { [weak self] result, model in
            guard let `self` = self else { return }
            let dataModel = AIEditingMainModel(editInfo: result)
            self.editingModel = dataModel.deepCopy() as! AIEditingMainModel
            self.dataModel = dataModel
            self.tableView.reloadData()
        }errorBlock: { [weak self] code, errStr  in
            guard let `self` = self else { return }
            if code == ResponseErrorCode.aiDeleted.rawValue {
                APPIMManager.share.deleteAiConversation(aiMid: self.mid ?? 0)
                self.deleteAIHandle?(self.mid ?? 0)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    /// 提交文件
    private func uploadPictures(model: AIEditingGalleryModel, complete: ((Bool, AIEditMainGalleryModel?) -> Void)?) {
        
        if model.url.isValidStr && model.photoAsset?.originalImage == nil {
            AppRequest(CreateModuleApi.diyUploadImage(type: model.type, url: model.url, file: nil), modelType: AIEditMainGalleryModel.self, showErrorTip: false) { result, data in
                
                model.url = result.url
                model.id = result.id
                complete?(true, result)
            }errorBlock: { code, msg in
                if code == ResponseErrorCode.uploadPic_illegal.rawValue {
                    model.isDelete = true
                }
                complete?(false, nil)
            }
            
        }else {
            guard let originImage = model.photoAsset?.originalImage else {
                complete?(false, nil)
                return
            }
            
            AppHXPhotoConfig.compressdImage(image: originImage, fileSize: 9) { imgData in
                AppRequest(CreateModuleApi.diyUploadImage(type: model.type, url: model.url, file: imgData), modelType: AIEditMainGalleryModel.self, showErrorTip: false) { result, data in
                    
                    model.url = result.url
                    model.id = result.id
                    complete?(true, result)
                }errorBlock: { code, msg in
                    if code == ResponseErrorCode.uploadPic_illegal.rawValue {
                        model.isDelete = true
                    }
                    complete?(false, nil)
                }
            }
        }
                
    }
    
    /// 创建新AI
    private func createNewAICheck() {
        if !self.tableFooterView.checkBtn.isSelected {
            self.tableFooterView.desLab.shake()
            return
        }
        
        // 网络判断
        let reachability = try? Reachability()
        if reachability?.connection == .unavailable {
            self.showErrorTipMsg(msg: "Network connection failed, please try again later")
            return
        }
        
        self.waitModelArray.removeAll()
        if mid != nil { // 编辑AI
            
            if dataModel.avatarAsset != nil, !dataModel.avatarAsset!.url.isValidStr {
                // 上传头像
                self.waitModelArray.append(dataModel.avatarAsset!)
            }
            
            if dataModel.greetAsset?.photoAsset != nil, !dataModel.greetAsset!.url.isValidStr {
                // 上传图片
                self.waitModelArray.append(dataModel.greetAsset!)
            }
         
        }else {
            if dataModel.avatarAsset != nil, dataModel.avatarAsset?.id == 0 {
                // 上传头像
                self.waitModelArray.append(dataModel.avatarAsset!)
            }
            
            if dataModel.greetAsset?.photoAsset != nil, dataModel.greetAsset?.id == 0 {
                // 上传图片
                self.waitModelArray.append(dataModel.greetAsset!)
            }
           
        }
        
        if dataModel.photoAssets.count > 0 {
            // 上传相册
            let tempArr = dataModel.photoAssets.filter({ $0.id == 0 })
            self.waitModelArray.append(contentsOf: tempArr)
        }
                
        self.showLoading(text: "Uploading...")
        if self.waitModelArray.count > 0 {
            let group = Dispatch.DispatchGroup()
            let uploadQueue = DispatchQueue(label: "createNewAI")
            
            self.waitModelArray.forEach { subModel in
                group.enter()
                uploadQueue.async(group: group, execute: {
                    self.uploadPictures(model: subModel) { status, result in
                        group.leave()
                    }
                })
            }
            
            group.notify(queue: DispatchQueue.main) {
                let tempArr = self.waitModelArray.filter({ $0.id == 0 })
                if tempArr.count == 0 {
                    self.checkAllContent()
                }else {
                    ProgressHUD.dismiss()
                    /// 有违规的
                    if self.waitModelArray.first(where: { $0.isDelete }) != nil {
                        self.showErrorTipMsg(msg: "Image violation, deleted")
                        self.removeIlleagalImages()
                        
                    }else {
                        self.showErrorTipMsg(msg: "Image upload failed, please try again")
                    }
                }
            }
            
        }else {
            self.checkAllContent()
        }
    }
   
    /// 文本检测
    private func checkAllContent() {
                
        if self.contentIllegal {
            self.saveNewAIRequest()
            return
        }
        
        let nick = AIEditContentReqModel(text: dataModel.nick, type: 2)
        let intro = AIEditContentReqModel(text: dataModel.intro, type: 3)
        let greet = AIEditContentReqModel(text: dataModel.greetStr, type: 4)
        let list = [nick.toDictionary(), intro.toDictionary(), greet.toDictionary()]
        let params: [String: Any] = ["checkList": list, "isFilter": dataModel.isFilter]
        
        AppRequest(CreateModuleApi.createAICheckText(params: params), modelType: AIEditContentResponseModel.self) { [weak self] result, model in
            guard let `self` = self else { return }
            if result.illegalType.count == 0 {
                self.saveNewAIRequest()
            }else {
                ProgressHUD.dismiss()
                self.illegalType = result.illegalType
                self.tableView.reloadData()
            }
        } errorBlock: { code, msg in
            ProgressHUD.dismiss()
        }
    }
    
    // 创建/保存
    private func saveNewAIRequest() {
                
        var params: [String: Any] = ["nickname": dataModel.nick.trimmingCharacters(in: .whitespacesAndNewlines),
                                     "sex": dataModel.sex.rawValue,
                                     "isShow": dataModel.isShow,
                                     "tags": dataModel.tags,
                                     "profile": dataModel.intro.trimmingCharacters(in: .whitespacesAndNewlines),
                                     "greeting": dataModel.greetStr.trimmingCharacters(in: .whitespacesAndNewlines)]
        
        if mid == nil {
            params["isFilter"] = dataModel.isFilter
        }else {
            params["mid"] = self.mid!
        }
        
        if let id = dataModel.avatarAsset?.id {
            params["headPicId"] = id
        }
        
        if let id = dataModel.greetAsset?.id {
            params["greetingId"] = id
        }else {
            params["greetingId"] = -1
        }
        
        let ids = dataModel.photoAssets.filter({ $0.id > 0 }).map { $0.id }
        if ids.count > 0 {
            params["galleryIds"] = ids
        }else {
            params["galleryIds"] = []
        }
        
        if dataModel.personal.isValidStr {
            params["backgrond"] = dataModel.personal.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if mid != nil {
            AppRequest(CreateModuleApi.aiModify(params: params), modelType: BaseSmartModel.self) { [weak self] result, model in
                guard let `self` = self else { return }
                ProgressHUD.dismiss()
                self.showSuccessTipMsg(msg: "Saved successfully")
                self.modifySuccessHandle?(self.dataModel, self.mid)
                self.navigationController?.popViewController(animated: true)
            }errorBlock: { code, msg in
                ProgressHUD.dismiss()
            }
        }else {
            AppRequest(CreateModuleApi.createAI(params: params), modelType: BaseSmartModel.self) { [weak self] result, model in
                guard let `self` = self else { return }
                ProgressHUD.dismiss()
                self.showSuccessTipMsg(msg: "Created successfully")
                self.navigationController?.popViewController(animated: false)
                self.createNewSuccessHandle?(result.mid)
            }errorBlock: { code, msg in
                ProgressHUD.dismiss()
            }
        }
        
        
    }
}

extension AIEditMainController {
    private func showNaviBackPopView() {
        var config = AlertConfig()
        let text = self.mid == nil ? "filled" : "modified"
        config.content = "The \(text) contents will not be saved after exiting. Are you sure you want to exit?"
        config.confirmTitle = "Exit"
        let pop = BaseAlertView(config: config) { [weak self] actionIndex in
            guard let `self` = self else { return }
            if actionIndex == 2 {
                self.navigationController?.popViewController(animated: true)
            }
        }
        pop.show()
    }
    
    private func updateAllStatus() {
        if mid == nil {
            let isEnable: Bool = dataModel.avatarAsset != nil
            && dataModel.nick.isValidStr
            && dataModel.sex != .unowned
            && dataModel.isShow > 0
            && dataModel.isFilter > 0
            && dataModel.tags.count > 0
            && dataModel.intro.isValidStr
            && dataModel.greetStr.isValidStr

            self.createBtn.setTitle("Create Character", for: .normal)
            self.createBtn.isEnabled = isEnable
            
        }else {
            /// 必填项检查
            let isFilled: Bool = dataModel.avatarAsset != nil
            && dataModel.nick.isValidStr
            && dataModel.sex != .unowned
            && dataModel.isShow > 0
            && dataModel.tags.count > 0
            && dataModel.intro.isValidStr
            && dataModel.greetStr.isValidStr
            
            /// 差异对比
            let isDifferent: Bool = dataModel.avatarAsset?.url != editingModel.avatarAsset?.url
            || dataModel.nick != editingModel.nick
            || dataModel.sex != editingModel.sex
            || dataModel.isShow != editingModel.isShow
            || dataModel.tags != editingModel.tags
            || dataModel.intro != editingModel.intro
            || dataModel.greetStr != editingModel.greetStr
            || dataModel.greetAsset?.url != editingModel.greetAsset?.url
            || dataModel.personal != editingModel.personal
            || dataModel.photoAssets.map({ $0.id }) != editingModel.photoAssets.map({ $0.id })
            
            self.createBtn.setTitle("Save", for: .normal)
            self.createBtn.isEnabled = isFilled && isDifferent
        }
        
    }
    
    private func showTagsPopView() {
        
        let pop = AIEditTagsPopView(selected: dataModel.tags, isFilter: dataModel.isFilter)
        pop.dataTags = dataModel.tags
        pop.show()
        pop.saveSelectedTagsHandle = { [weak self] tags in
            guard let `self` = self else { return }
            self.dataModel.tags = tags
            self.updateAllStatus()
            self.reloadTableView(with: .tags)
        }
    }
    
    private func reloadTableView(with type: AIEditSectionType) {
        guard let index = self.dataArray.firstIndex(where: { $0 == type }) else {
            return
        }
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func removeIlleagalImages() {
        if dataModel.avatarAsset?.isDelete ?? false {
            dataModel.avatarAsset = nil
        }
        
        if dataModel.greetAsset?.isDelete ?? false {
            dataModel.greetAsset = nil
        }
        
        dataModel.photoAssets.removeAll(where: { $0.isDelete == true })
        self.tableView.reloadData()
        self.updateAllStatus()
    }
 
}

// MARK: - AIEditMainCellDelegate
extension AIEditMainController: AIEditMainCellDelegate {
    /// 更换头像
    func onChangeAvatar(cell: AIEditMainCell?) {
        pickerAction = .avatar
        let config = AppHXPhotoConfig.avatarConfig()
        let picker = PhotoPickerController(config: config)
        picker.pickerDelegate = self
        self.present(picker, animated: true)
    }
    
    /// 编辑昵称
    func onEditNickname(cell: AIEditMainCell?, text: String?) {
        self.dataModel.nick = text ?? ""
        self.contentIllegal = false
        if illegalType.contains(2) {
            illegalType.removeAll { $0 == 2 }
            self.reloadTableView(with: .name)
        }
        self.updateAllStatus()
    }
    
    /// 选择性别
    func onChangeSex(cell: AIEditMainCell?, sex: UserSexType) {
        self.view.endEditing(true)
        self.dataModel.sex = sex
        self.updateAllStatus()
    }
    
    /// 选择公开私有
    func onChangeOwnership(cell: AIEditMainCell?, isShow: Int) {
        self.view.endEditing(true)
        self.dataModel.isShow = isShow
        self.updateAllStatus()
    }
    
    /// 评级过滤
    func onChangeFilter(cell: AIEditMainCell?, isFilter: Int) {
        self.view.endEditing(true)
        self.dataModel.isFilter = isFilter
        let filterIds = APPManager.default.config.tagList.filter({ $0.is_filter == 2 }).map({ $0.id })
        if self.dataModel.tags.first(where: { filterIds.contains($0) }) != nil {
            self.showErrorTipMsg(msg: "Unable to select unfiltered label under filter category")
            let tags = self.dataModel.tags.filter({ filterIds.contains($0) == false })
            self.dataModel.tags = tags
            self.reloadTableView(with: .tags)
        }
        self.updateAllStatus()
    }
    
    /// tags
    func onChangeSelectedTags(cell: AIEditMainCell?) {
        self.view.endEditing(true)
        self.showTagsPopView()
    }
    
    /// intro
    func onEditIntro(cell: AIEditMainCell?, text: String?) {
        self.dataModel.intro = text ?? ""
        self.contentIllegal = false
        if illegalType.contains(3) {
            illegalType.removeAll { $0 == 3 }
            self.reloadTableView(with: .intro)
        }
        self.updateAllStatus()
    }
    
    /// 打招呼
    func onEditGreeting(cell: AIEditMainCell?, text: String?) {
        self.dataModel.greetStr = text ?? ""
        self.contentIllegal = false
        if illegalType.contains(4) {
            illegalType.removeAll { $0 == 4 }
            self.reloadTableView(with: .greet)
        }
        self.updateAllStatus()
    }
    
    /// 打招呼图片
    func onChangeGreetingPic(cell: AIEditMainCell?, isDelete: Bool) {
        if isDelete {
            self.dataModel.greetAsset = nil
            self.updateAllStatus()
            self.reloadTableView(with: .greet)
        }else {
            pickerAction = .greet
            let config = AppHXPhotoConfig.onlyOnePhoto()
            let picker = PhotoPickerController(config: config)
            picker.pickerDelegate = self
            self.present(picker, animated: true)
        }
        
    }
    
    /// 9图-选填
    func onChangeGalleryPic(cell: AIEditMainCell?, last: [AIEditingGalleryModel], isDelete: Bool) {
        if isDelete {
            self.dataModel.photoAssets = last
            self.updateAllStatus()
            self.reloadTableView(with: .pic)
        }else {
            pickerAction = .pic
            let config = AppHXPhotoConfig.addMorePhotos(maxCount: 9)
            let picker = PhotoPickerController(config: config)
            let lastSelected = last.filter({ $0.photoAsset != nil }).map({ $0.photoAsset! })
            picker.selectedAssetArray = lastSelected
            picker.pickerDelegate = self
            self.present(picker, animated: true)
        }
    }
    
    /// 性格背景-选填
    func onEditPersonality(cell: AIEditMainCell?, text: String?) {
        self.dataModel.personal = text ?? ""
        self.updateAllStatus()
    }
    
}

extension AIEditMainController: PhotoPickerControllerDelegate {
    func pickerController(_ pickerController: PhotoPickerController, didFinishSelection result: PickerResult) {
        pickerController.dismiss(true) {
            
            if self.pickerAction == .avatar {
                guard let asset = result.photoAssets.first else { return }
                self.dataModel.avatarAsset = AIEditingGalleryModel(asset: asset, type: "1")
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                
            }else if self.pickerAction == .greet {
                
                guard let asset = result.photoAssets.first else {
                    return
                }
                self.dataModel.greetAsset = AIEditingGalleryModel(asset: asset, type: "3")
                self.reloadTableView(with: .greet)
                
            }else {
               
                if self.mid == nil {
                    var list: [AIEditingGalleryModel] = []
                    result.photoAssets.forEach { asset in
                        let model = AIEditingGalleryModel.init(asset: asset, type: "2")
                        list.append(model)
                    }
                    self.dataModel.photoAssets = list
                    self.reloadTableView(with: .pic)
                }else {
                    var list: [AIEditingGalleryModel] = []
                    result.photoAssets.forEach { asset in
                        let model = AIEditingGalleryModel.init(asset: asset, type: "2")
                        if let lastModel = self.dataModel.photoAssets.first(where: { $0.photoAsset == asset }) {
                            model.url = lastModel.url
                            model.id = lastModel.id
                        }
                        
                        list.append(model)
                    }
                    self.dataModel.photoAssets = list
                    self.reloadTableView(with: .pic)

                }
                
                
            }
            
            self.pickerAction = nil
            self.updateAllStatus()
        }
    }
    
    func pickerController(didCancel pickerController: PhotoPickerController) {
        pickerAction = nil
        self.updateAllStatus()
    }
}


extension AIEditMainController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = dataArray[indexPath.row]
        let ID = AIEditingMainModel.getReuseId(type: type)
        let cell = tableView.dequeueReusableCell(withIdentifier: ID, for: indexPath) as! AIEditMainCell
        cell.delegate = self
        cell.loadEditMailCell(type: type, illegal: self.illegalType)
        cell.loadEditCellModel(dataModel)
        
        return cell
    }
}

extension AIEditMainController {
    private func createUI() {
        self.title = "Create New Character"
        view.addSubview(tableView)
        view.addSubview(createBtn)
    }
    
    private func createUILimit() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        createBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(48)
            make.bottom.equalTo(-47)
            make.height.equalTo(48)
        }
    }
    
    private func addEvent() {
        tableFooterView.checkBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.tableFooterView.checkBtn.isSelected = !self.tableFooterView.checkBtn.isSelected
        }).disposed(by: bag)
        
        createBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.createNewAICheck()
        }).disposed(by: bag)
    }
}
