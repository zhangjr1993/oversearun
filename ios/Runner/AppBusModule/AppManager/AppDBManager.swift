//
//  AppDBManager.swift
//  AIRun
//
//  Created by Bolo on 2025/2/11.
//

import UIKit

/// AI基本信息
let BasicAIDataTable = "BasicAIDataTable"

class AppDBManager: NSObject {
    static let `default` = AppDBManager()

    
    var dataBase: Database?

    private var dbName: String {
        get {
            if let uid = APPManager.default.loginUserModel?.user?.uid {
                return "oversea\(uid).db"
            }
            return "oversea_0_DB.db"
        }
    }
    
    public func connectDatabase() {
        if dataBase != nil{
            dataBase?.close()
        }
        guard let fileURL = try? FileManager.default
                        .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                        .appendingPathComponent(dbName) else { return }
        dataBase = Database(at: fileURL)
        
        createTable(table: BasicAIDataTable, of: ChatQueryInfoModel.self)
    }
    
    
    /// 创建表
    func createTable<T: TableDecodable>(table: String, of ttype:T.Type) -> Void {
        do {
            try dataBase?.create(table: table, of:ttype)
        } catch let error {
            debugPrint("create table error \(error.localizedDescription)")
        }
    }
    /// 插入
    func insertToDb<T: TableEncodable>(objects: [T] ,intoTable table: String) -> Void {
        guard dataBase != nil else {return}
        do {
            try dataBase?.insert(objects, intoTable: table)
        } catch let error {
            debugPrint(" insert obj error \(error.localizedDescription)")
        }
    }
    
    func insertOrReplaceToDB<T: TableEncodable>(objects: [T] ,intoTable table: String) -> Void {
        guard dataBase != nil else {return}
        do {
            try dataBase?.insertOrReplace(objects, intoTable: table)
        } catch let error {
            debugPrint("create table error \(error.localizedDescription)")
        }
    }
        
    /// 修改
    func updateToDb<T: TableEncodable>(table: String, on propertys:[PropertyConvertible],with object:T,where condition: Condition? = nil) -> Void{
        guard dataBase != nil else {return}
        do {
            try dataBase?.update(table: table, on: propertys, with: object,where: condition)
        } catch let error {
            debugPrint(" update obj error \(error.localizedDescription)")
        }
    }
    
    /// 删除
    func deleteFromDb(fromTable: String, where condition: Condition? = nil) -> Void {
        guard dataBase != nil else {return}
        do {
            try dataBase?.delete(fromTable: fromTable, where:condition)
        } catch let error {
            debugPrint("delete error \(error.localizedDescription)")
        }
    }
    /// 查询
    func qureyFromDb<T: TableDecodable>(fromTable: String, cls cName: T.Type, where condition: Condition? = nil, orderBy orderList:[OrderBy]? = nil) -> [T]? {
        
        guard dataBase != nil else {return nil}
        do {
            let allObjects: [T] = try (dataBase?.getObjects(fromTable: fromTable, where:condition, orderBy: orderList)) ?? []
            debugPrint("\(allObjects)")
            return allObjects
        } catch let error {
            debugPrint("no data find \(error.localizedDescription)")
        }
        return nil
    }

    /// 删除数据表
    func dropTable(table: String) -> Void {
        do {
            try dataBase?.drop(table: table)
        } catch let error {
            debugPrint("drop table error \(error)")
        }
    }
    /// 删除所有与该数据库相关的文件
    func removeDbFile() -> Void {
        do {
            try dataBase?.close(onClosed: { [self] in
                try dataBase?.removeFiles()
            })
        } catch let error {
            debugPrint("not close db \(error)")
        }
        
    }
}

extension AppDBManager {
    /// 批量更新AI
    func batchUpdateAIData(list: [ChatQueryInfoModel]) {
        list.forEach { model in
            let condition = ChatQueryInfoModel.Properties.mid == model.mid
            if let result = self.qureyFromDb(fromTable: BasicAIDataTable, cls: ChatQueryInfoModel.self, where: condition), result.count > 0 {
                
                self.updateToDb(table: BasicAIDataTable, on: ChatQueryInfoModel.Properties.all, with: model, where: condition)
            }else {
                self.insertToDb(objects: [model], intoTable: BasicAIDataTable)
            }
        }
    }
    
    func allBasicInfoForAI() -> [ChatQueryInfoModel] {
        return self.qureyFromDb(fromTable: BasicAIDataTable, cls: ChatQueryInfoModel.self) ?? []
    }
    
    func getAIBasicInfoData(mid: Int) -> ChatQueryInfoModel? {
        let condition = ChatQueryInfoModel.Properties.mid == mid
        return self.qureyFromDb(fromTable: BasicAIDataTable, cls: ChatQueryInfoModel.self, where: condition)?.first
    }
}
