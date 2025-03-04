//
//  CreateMainController.swift
//  AIRun
//
//  Created by AIRun on 2025/1/16.
//

import UIKit

class CreateMainController: BaseViewController {
    
    private var dataArray: [CreateMainListModel] = []
    private var page = 1
    private var hasNext = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.createUI()
        self.createUILimit()
        self.addEvent()
        self.beginRefresh()
    }
    
    private lazy var emptyView = CreateMainEmptyView().then {
        _ in
    }
    
    private lazy var tableView = BaseTableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.backgroundColor = .clear
        $0.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: 20))
        $0.register(CreateMainListCell.self, forCellReuseIdentifier: CreateMainListCell.description())
    }
   

}

extension CreateMainController {
    func loadDiyListData() {
        if !APPManager.default.isHasLogin(needJump: false) {
            self.refreshOriginUI()
            return
        }
        
        let params: [String: Any] = ["page": self.page]
        
        AppRequest(CreateModuleApi.diyAIList(params: params), modelType: CreateMainModel.self) { [weak self] listModel, model in
            guard let `self` = self else { return }
            if self.page == 1 {
                self.dataArray.removeAll()
                self.tableView.endRefresh()
            }
            self.hasNext = listModel.hasNext
            self.tableView.endNextLoadMoreData(next: listModel.hasNext)
            
            self.page += 1
            self.dataArray.append(contentsOf: listModel.list)
            self.tableView.reloadData()
            self.refreshOriginUI()
        }errorBlock: { [weak self] code, msg in
            self?.tableView.endRefresh()
            self?.refreshOriginUI()
        }
    }
    
    private func refreshOriginUI() {
        self.tableView.isHidden = self.dataArray.count == 0
        let adaptH = self.emptyView.updateUI(isEmpty: self.dataArray.count == 0)
        self.emptyView.snp.updateConstraints { make in
            make.height.equalTo(adaptH)
        }
    }
    
    private func deleteAIRequest(mid: Int) {
        AppRequest(CreateModuleApi.deleteAI(params: ["mid": mid]), modelType: BaseSmartModel.self) { [weak self] result, model in
            guard let `self` = self else { return }
            self.afterDeleteAIRefresh(mid: mid)
        }
    }
    
    private func afterDeleteAIRefresh(mid: Int) {
        guard let index = dataArray.firstIndex(where: { $0.mid == mid }) else { return }
        self.dataArray.remove(at: index)
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        self.tableView.endUpdates()
        NotificationCenter.default.post(name: .aiDeletedUpdated, object: ["mid": mid])
        /// 删完当前页
        guard self.dataArray.count == 0 else { return }
        if self.hasNext {
            self.beginRefresh()
        }else {
            self.emptyView.updateUI(isEmpty: true)
            self.tableView.isHidden = true
        }
    }
    
}

extension CreateMainController {
    private func showUploadRemindPopView() {
        let pop = CreateUploadTipPopView()
        pop.show()
        pop.uploadFileHandle = { [weak self] in
            guard let `self` = self else { return }
            self.showDocumentMenu()
        }
    }
    
    private func showDocumentMenu() {
        let documentTypes = ["public.image", "public.json"]
        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    private func parseJsonData(_ data: Data) -> ([String: Any]?, [String: Any]?) {
        guard let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return (nil, nil)
        }
        
        let parsedDict = parseJsonStructure(jsonDict)
        return (parsedDict, jsonDict)
    }
    
    private func parseJsonStructure(_ dict: [String: Any]) -> [String: Any] {
        var resultDict: [String: Any] = [:]
        
        func parseValue(_ value: Any) {
            if let nestedDict = value as? [String: Any] {
                searchKeysInDict(nestedDict)
            } else if let array = value as? [Any] {
                for item in array {
                    parseValue(item)
                }
            }
        }
        
        func searchKeysInDict(_ dict: [String: Any]) {
            for (key, value) in dict {
                let lowercaseKey = key.lowercased()
                
                // Check for nickname
                if lowercaseKey.contains("name") || lowercaseKey.contains("nick") || lowercaseKey.contains("nickname") {
                    if resultDict["nickname"] == nil {
                        resultDict["nickname"] = value
                        continue
                    }
                }
                
                // Check for avatar
                if (lowercaseKey.contains("avatar") || lowercaseKey.contains("header")),
                   let urlString = value as? String,
                   (urlString.hasPrefix("http://") || urlString.hasPrefix("https://")) {
                    if resultDict["avatar"] == nil {
                        resultDict["avatar"] = value
                        continue
                    }
                }
                
                // Check for tags
                if lowercaseKey.contains("tags") {
                    if resultDict["tags"] == nil {
                        resultDict["tags"] = value
                        continue
                    }
                }
                
                // Check for personality
                if lowercaseKey.contains("personal") || lowercaseKey.contains("background") {
                    if resultDict["personality"] == nil {
                        resultDict["personality"] = value
                        continue
                    }
                }
                
                // Check for intro
                if lowercaseKey.contains("intro") || lowercaseKey.contains("profile") {
                    if resultDict["intro"] == nil {
                        resultDict["intro"] = value
                        continue
                    }
                }
                
                // Recursively search nested structures
                parseValue(value)
            }
        }
        
        searchKeysInDict(dict)
        return resultDict
    }
    
    private func extractBase64FromImage(_ imageData: Data) -> ([String: Any]?, [String: Any]?) {
        guard let imageString = String(data: imageData, encoding: .utf8) else {
            return (nil, nil)
        }
        
        // Find the base64 string starting with "tExtchara"
        let pattern = "tExtchara[A-Za-z0-9+/]*=*"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: imageString, options: [], range: NSRange(imageString.startIndex..., in: imageString)) else {
            return (nil, nil)
        }
        
        // Extract the matched base64 string
        guard let range = Range(match.range, in: imageString) else {
            return (nil, nil)
        }
        let base64String = String(imageString[range])
        
        // Remove "tExtchara" prefix
        let cleanBase64 = base64String.replacingOccurrences(of: "tExtchara", with: "")
        
        // Decode base64
        guard let decodedData = Data(base64Encoded: cleanBase64),
              let jsonDict = try? JSONSerialization.jsonObject(with: decodedData, options: []) as? [String: Any] else {
            return (nil, nil)
        }
        
        let parsedDict = parseJsonStructure(jsonDict)
        return (parsedDict, jsonDict)
    }
    
    private func showCellMorePopView(mid: Int, point: CGPoint) {
        let pop = CreateMainEditPopView(point: point)
        pop.show()
        pop.clickMainEditPopViewHandle = { [weak self] tag in
            guard let `self` = self else { return }
            if tag == 1 {
                self.pushEditMainController(mid)
            }else if tag == 2 {
                self.pushChatController(mid: mid)
            }else {
                self.showDeleteAlert(mid: mid)
            }
        }
    }
        
    private func showDeleteAlert(mid: Int) {
        var config = AlertConfig()
        config.content = "Are you sure you want to delete this AI character?"
        config.confirmTitle = "Delete"
        let pop = BaseAlertView(config: config) { [weak self] actionIndex in
            guard let `self` = self else { return }
            if actionIndex == 2 {
                self.deleteAIRequest(mid: mid)
            }
        }
        pop.show()
    }
}

extension CreateMainController {
    private func pushEditMainController(_ mid: Int?) {
        let vc = AIEditMainController(mid: mid)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.createNewSuccessHandle = { [weak self] result in
            guard let `self` = self else { return }
            self.beginRefresh()
            self.pushChatController(mid: result)
        }
        vc.modifySuccessHandle = { [weak self] result, mmid in
            guard let `self` = self else { return }
            self.beginRefresh()
        }
        vc.deleteAIHandle = { [weak self] mid in
            guard let `self` = self else { return }
            self.afterDeleteAIRefresh(mid: mid)
        }
    }
    
    private func pushChatController(mid: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            APPPushManager.default.pushToChatView(aiMID: mid)
        })
    }
}

extension CreateMainController {
    func createUI() {
        self.hideNaviBar = true
        view.addSubview(emptyView)
        view.addSubview(tableView)
    }
    
    func createUILimit(){
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(UIScreen.statusBarHeight)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(280)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(emptyView.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func addEvent() {
        
        tableView.addMJRefreshHeader { [weak self] in
            guard let `self` = self else { return }
            self.beginRefresh()
        }
        
        tableView.addMJBackStateFooter { [weak self] in
            guard let `self` = self else { return }
            self.loadDiyListData()
        }
        
        emptyView.createBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if APPManager.default.isHasLogin() {
                self.pushEditMainController(nil)
            }
            
        }).disposed(by: bag)
        
        emptyView.uploadBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if APPManager.default.isHasLogin() {
                self.showUploadRemindPopView()
            }
        }).disposed(by: bag)
        
    }
    
    private func beginRefresh() {
        self.page = 1
        self.loadDiyListData()
    }
}

extension CreateMainController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreateMainListCell.description(), for: indexPath) as! CreateMainListCell
        cell.loadCellData(dataArray[indexPath.row])
        cell.clickCellMoreHandle = { [weak self] mid, point in
            guard let `self` = self else { return }
            self.showCellMorePopView(mid: mid, point: point)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) as? CreateMainListCell {
//            let model = dataArray[indexPath.row]
//            let point = cell.moreBtn.convert(CGPoint.zero, toViewOrWindow: UIApplication.key)
//            self.showCellMorePopView(mid: model.mid, point: point)
//        }
    }
    
   
}

// Add UIDocumentPickerDelegate
extension CreateMainController: UIDocumentPickerDelegate {
    private struct PNGError: LocalizedError {
        let message: String
        var errorDescription: String? { return message }
        
        static let invalidPNG = PNGError(message: "Invalid PNG format")
        static let noCharacterData = PNGError(message: "No character data found")
        static let invalidCharacterData = PNGError(message: "Unable to parse character data")
    }
    
    private func verifyPNGData(_ data: Data) -> String? {
        // Convert Data to [UInt8]
        let bytes = [UInt8](data)
        
        // Verify PNG header
        let pngHeader: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        guard bytes.count >= 8 && bytes.prefix(8).elementsEqual(pngHeader) else {
            return nil
        }
        
        var offset = 8
        var foundChara = false
        var characterData = ""
        
        // Parse PNG chunks
        while offset < bytes.count {
            // Read chunk length (4 bytes)
            guard offset + 4 <= bytes.count else { break }
            let length = (Int(bytes[offset]) << 24) |
                        (Int(bytes[offset + 1]) << 16) |
                        (Int(bytes[offset + 2]) << 8) |
                        Int(bytes[offset + 3])
            offset += 4
            
            // Read chunk type (4 bytes)
            guard offset + 4 <= bytes.count else { break }
            let type = String(bytes: bytes[offset..<offset + 4], encoding: .ascii) ?? ""
            offset += 4
            
            // Check for tEXt chunk
            if type == "tEXt" {
                // Find keyword end (null terminator)
                var keywordEnd = offset
                while keywordEnd < offset + length && bytes[keywordEnd] != 0 {
                    keywordEnd += 1
                }
                
                // Read keyword
                if let keyword = String(bytes: bytes[offset..<keywordEnd], encoding: .ascii),
                   keyword == "chara" {
                    foundChara = true
                    
                    // Read text data
                    let textStart = keywordEnd + 1
                    let textEnd = offset + length
                    if let textData = String(bytes: bytes[textStart..<textEnd], encoding: .ascii) {
                        // Decode base64
                        if let decodedData = Data(base64Encoded: textData),
                           let decodedString = String(data: decodedData, encoding: .utf8) {
                            characterData = decodedString
                            break
                        }
                    }
                }
            }
            
            // Skip to next chunk (including CRC)
            offset += length + 4
        }
        
        return foundChara ? characterData : nil
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        
        // Ensure the URL is a file URL
        guard selectedFileURL.isFileURL else { return }
        
        // Start accessing the security-scoped resource
        let didStartAccessing = selectedFileURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                selectedFileURL.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let fileData = try Data(contentsOf: selectedFileURL)
            let fileName = selectedFileURL.lastPathComponent.lowercased()
            var parsedDict: [String: Any]?
            /// 原始数据
            var originalDict: [String: Any]?
            
            // Check file type
            if fileName.hasSuffix(".json") {
                // Handle JSON file
                (parsedDict, originalDict) = parseJsonData(fileData)
            } else if fileName.hasSuffix(".png") || fileName.hasSuffix(".jpg") || fileName.hasSuffix(".jpeg") {
                // Handle image file
                if let jsonString = verifyPNGData(fileData),
                   let jsonData = jsonString.data(using: .utf8) {
                    (parsedDict, originalDict) = parseJsonData(jsonData)
                } else {
                    throw PNGError.noCharacterData
                }
            }
            
            if let parsed = parsedDict {
                
                let model = AIEditingMainModel(parsed: parsed, origin: originalDict, fileURL: selectedFileURL)
                let vc = AIEditMainController(upload: model)
                self.navigationController?.pushViewController(vc, animated: true)
                vc.createNewSuccessHandle = { [weak self] result in
                    guard let `self` = self else { return }
                    self.beginRefresh()
                    self.pushChatController(mid: result)
                }
                
            } else {
                throw PNGError.invalidCharacterData
            }
            
        } catch let error as PNGError {
            print("PNG Error: \(error.localizedDescription)")
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        } catch {
            print("Error accessing file: \(error.localizedDescription)")
            let alert = UIAlertController(title: "Error", message: "Unable to access the selected file.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled")
    }
}
