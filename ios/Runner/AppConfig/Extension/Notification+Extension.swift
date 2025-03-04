//
//  Noti+Extension.swift
//  AIRun
//
//  Created by AIRun on 2025/1/15.
//


extension Notification.Name {
    
    /// 首页Tab/Tags更新
    static let appConfigTabsUpdate = Notification.Name("appConfigTabsUpdate")
    static let appConfigTagsUpdate = Notification.Name("appConfigTagsUpdate")

    /// 用户相关
    static let userDidLogin = Notification.Name("userDidLogin")

    static let userProfileUpdated = Notification.Name("userProfileUpdated")
    static let userInfoNeedUpdated = Notification.Name("userInfoNeedUpdated")

    /// 关注/取消关注 mid, status, tab
    static let aiAttentionUpdated = Notification.Name("userAttentionUpdated")
    /// 拉黑/取消拉黑 uid，status
    static let userBlockedUpdated = Notification.Name("userBlockedUpdated")
    /// 拉黑/取消拉黑 mid, status
    static let aiBlockedUpdated = Notification.Name("aiBlockedUpdated")
    /// 删除AI mid
    static let aiDeletedUpdated = Notification.Name("aiDeletedUpdated")
    /// 刷新getMyinfo
    static let needRefreshMyInfo = Notification.Name("needRefreshMyInfo")
    /// 设置过滤开关变更
    static let userFilterUpdate = Notification.Name("userFilterUpdate")
    
    
}
