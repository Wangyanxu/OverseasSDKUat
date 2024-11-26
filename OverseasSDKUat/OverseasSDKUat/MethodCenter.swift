//
//  MethodCenter.swift
//  OverseasSDKUat
//
//  Created by wangyanxu on 2024/11/5.
//

import Foundation
import CommsayChatSDK


class MethodCenter: NSObject, ConnectionDelegate {
    static let shared = MethodCenter()
    
    // 用来存储对象的属性
    var groupChannel: GroupChannel?
    var openChannel: OpenChannel?
    var subChannel: GroupSubchannel?
    var message: BaseMessage?
    var currentUser: CommsayChatSDK.User?
    
    static func getElementAtIndex<T>(from array: [T], at index: Int) -> T? {
        if array.indices.contains(index) {
            return array[index]
        } else {
            return nil
        }
    }
    
    static func convertToUInt(from input: String, defaultValue: UInt = 0) -> UInt {
        if let uintValue = UInt(input) {
            return uintValue  // 成功转换为 UInt
        } else {
            return defaultValue  // 转换失败时，返回 0
        }
    }
   
}

// MARK: - 连接
extension MethodCenter {
    
    /// 初始化
    @objc static func initialize(_ paramsString: String) {
//        let paramsForInit = InitializeParams(appKey: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) ?? "")
//        
        let paramsForInit = InitializeParams(appKey: "8w7jv4q77xuyy", naviHost: "https://nav-cmsyqa.rongcloud.net", fileHost: "", statisticHost: "", logHost: "")

//        let areaCodeString = getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1)
//        if let areaCodeString = areaCodeString, let areaCodeUInt = UInt(areaCodeString) {
//            paramsForInit.areaCode = AreaCode(rawValue: areaCodeUInt) ?? .singapore
//        }
        
        paramsForInit.logLevel = .debug;
        let logLevelString = getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 2)
        if let logLevelString = logLevelString, let logLevelUInt = UInt(logLevelString) {
            paramsForInit.logLevel = LogLevel(rawValue: logLevelUInt) ?? .debug
        }
        CommsayChat.initialize(params: paramsForInit)
        UatLogPannel.log("初始化" + paramsString)
    }
    
//    {"user_id":"211226","name":"name","portrait_url":"portrait_url","access_token":"QY8DqillWZmgzf0R08rnOGT5pVJE+PemCg3AAXdOuRDJ7wgRseLMaM3G29mdsQ246RnhtwdJFzQrOcRY1mOdkA==","is_online":false}%
//          
//    {"user_id":"211227","name":"name","portrait_url":"portrait_url","access_token":"qFTg+q3g/srLqXbZPtCGNUBEefWu1T7JIGtDSfckNCZSTQ6iQT+W+hrEXTOBduUgCmEhlZpRFPN2tV6Kg8nRlw==","is_online":false}%
    
    /// 连接
    @objc static func connect(_ paramsString: String) {
        
//        let params = ConnectParams(userId: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) ?? "", token: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1) ?? "")
        let params = ConnectParams(userId: "211226", token: "QY8DqillWZmgzf0R08rnOGT5pVJE+PemCg3AAXdOuRDJ7wgRseLMaM3G29mdsQ246RnhtwdJFzQrOcRY1mOdkA==")

        
        let timeoutString = getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 2)
        if let timeoutString = timeoutString, let timeoutInt = Int(timeoutString) {
            params.timeout = timeoutInt
        }
        
        UatLogPannel.log("连接" + paramsString)
        
        CommsayChat.connect(params: params) { user, error in
            if let e = error {
                UatLogPannel.log("连接" + e.debugDescription)
                return
            }
            MethodCenter.shared.currentUser = user
            UatLogPannel.log("连接" + (user?.id ?? "") + (user?.name ?? "") + (user?.portraitUrl ?? ""))
        }
    }
    
}

// MARK: - 消息
extension MethodCenter {
    /// 发送自定义消息
    @objc static func sendCustomMessage(_ paramsString: String){
        let parts = paramsString.split(separator: ";")
        var resultDict = [String: String]()
        if let firstPart = parts.first {
            // 第二步：用“,”分割
            let pairs = firstPart.split(separator: ",")
            // 第三步：用“:”分割并存入字典
            for pair in pairs {
                let keyValue = pair.split(separator: ":")
                if keyValue.count == 2 {
                    let key = String(keyValue[0])
                    let value = String(keyValue[1])
                    resultDict[key] = value
                }
            }
        }
        let policyString = paramsString.components(separatedBy: ";")[2]
        var messagePolicy: Int?
        if let policyInt = Int(policyString) {
            messagePolicy = policyInt
        } else {
            messagePolicy = 0
        }
        let params = CustomMessageCreateParams(metadata: resultDict, customType: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1) ?? "messageType", policy: CustomMessagePolicy(rawValue: messagePolicy!) ?? CustomMessagePolicy.normal)
        UatLogPannel.log("发送自定义消息 " + paramsString)
        switch getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 2) {
        case "1":
            MethodCenter.shared.openChannel?.sendCustomMessage(params: params){ (customMsg: CustomMessage?) in
                // The body of the message being sent
            } completionHandler: { (customMsg: CustomMessage?, error: ChatError?) in
                if let e = error {
                    // Handle error.
                    UatLogPannel.log("Open 发送自定义消息  " + e.debugDescription)
                    return
                }
                UatLogPannel.log("Open 发送自定义消息 " + (customMsg?.messageUId ?? ""))
                MethodCenter.shared.message = customMsg;
                // Handle the message that has been successfully sent
            }
        default:
            MethodCenter.shared.subChannel?.sendCustomMessage(params: params) { (customMsg: CustomMessage?) in
                // The body of the message being sent
            } completionHandler: { (customMsg: CustomMessage?, error: ChatError?) in
                if let e = error {
                    // Handle error.
                    UatLogPannel.log("Gro 发送自定义消息  " + e.debugDescription)
                    return
                }
                UatLogPannel.log("Gro 发送自定义消息 " + (customMsg?.messageUId ?? ""))
                MethodCenter.shared.message = customMsg;
                // Handle the message that has been successfully sent
            }
        }
    }
    
    /// 发送普通消息
    @objc static func sendTextMessage(_ paramsString: String){
        UatLogPannel.log("发送文本消息 " + paramsString)
        let params = TextMessageCreateParams(content: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1)!)
        let metionTypeString = getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 2)
        let metionUserIdsString = getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 3)
        let metionMessageString = getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 4)
        if (metionTypeString != nil) {
            if metionTypeString == "0" {
                params.mentionType = .users
            }
            else {
                params.mentionType = .channel
            }
            params.mentionedUserIds = metionUserIdsString?.components(separatedBy: ",")
            params.mentionedMessage = metionMessageString
            UatLogPannel.log("发送文本消息设置 @ 参数")
        }
        switch getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) {
        case "1":
            MethodCenter.shared.openChannel!.sendTextMessage(params: params) { (textMsg: TextMessage?) in
                        // The body of the message being sent
                UatLogPannel.log("Open 发送文本消息 The body of the message being sent")
            } completionHandler: { (textMsg: TextMessage?, error: ChatError?) in
                if let e = error {
                    UatLogPannel.log("Open 发送文本消息 " + e.description)
                    return
                }
                UatLogPannel.log("Open 发送文本消息  " + textMsg!.messageUId)
                MethodCenter.shared.message = textMsg;
            }
        default:
            MethodCenter.shared.subChannel!.sendTextMessage(params: params) { (textMsg: TextMessage?) in
                        // The body of the message being sent
                UatLogPannel.log("Gro 发送文本消息 The body of the message being sent")
            } completionHandler: { (textMsg: TextMessage?, error: ChatError?) in
                if let e = error {
                    UatLogPannel.log("Gro 发送文本消息 " + e.description)
                    return
                }
                UatLogPannel.log("Gro 发送文本消息  " + textMsg!.messageUId)
                MethodCenter.shared.message = textMsg;
            }
        }
    }
    
    /// 发送文件消息
    @objc static func sendFileMessage(_ paramsString: String){
        UatLogPannel.log("发送文件消息 " + paramsString)
        let metionTypeString = getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 2)
        let metionUserIdsString = getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 3)
        let metionMessageString = getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 4)
        if getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1) == "1" {
//            // 如果您想要在 open channel 中发送消息，将实例 subchannel 替换为 openchannel
//            let params = FileMessageCreateParams(file: <#T##Data#>)
//
//            // 如果是图片类型的文件消息，可配置缩略图，最多 3 个
//            let thumbnailParams1 = ThumbnailCreateParams()
//            thumbnailParams1.maxSize = CGSize(width: 100, height: 100)
//            let thumbnailParams2 = ThumbnailCreateParams()
//            thumbnailParams2.maxSize = CGSize(width: 120, height: 120)
//            params.thumbnails = [thumbnailParams1, thumbnailParams2]
//            if (metionTypeString != nil) {
//                if metionTypeString == "0" {
//                    params.mentionType = .users
//                }
//                else {
//                    params.mentionType = .channel
//                }
//                params.mentionedUserIds = metionUserIdsString?.components(separatedBy: ",")
//                params.mentionedMessage = metionMessageString
//                UatLogPannel.log("发送文件消息设置 @ 参数")
//            }
//            switch getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) {
//            case "1":
//                MethodCenter.shared.openChannel!.sendTextMessage(params: params) { (textMsg: TextMessage?) in
//                            // The body of the message being sent
//                    UatLogPannel.log("Open 发送文件消息 The body of the message being sent")
//                } completionHandler: { (textMsg: TextMessage?, error: ChatError?) in
//                    if let e = error {
//                        UatLogPannel.log("Open 发送文件消息 " + e.description)
//                        return
//                    }
//                    UatLogPannel.log("Open 发送文件消息  " + textMsg!.messageUId)
//                    MethodCenter.shared.message = textMsg;
//                }
//            default:
//                MethodCenter.shared.subChannel!.sendFileMessage(params) { (fileMsg: FileMessage?) in
//                    UatLogPannel.log("Gro 发送文件消息 The body of the message being sent")
//                } progressHandler: { (fileMsg: FileMessage?, progress: Int) in
//                    // Handle sending progress, because file messages need to be uploaded.
//                } completionHandler: { (fileMsg: FileMessage?, error: ChatError?) in
//                    if let e = error {
//                        UatLogPannel.log("Gro 发送文件消息 " + e.description)
//                        return
//                    }
//                    UatLogPannel.log("Gro 发送文件消息  " + FileMessage!.messageUId)
//                    MethodCenter.shared.message = fileMsg;
//                }
//            }
        }
        else {
            let params = FileMessageCreateParams(fileURL: "https://example.com/example.png")
            params.fileName = "testname"
            params.fileSize = 200
            params.mimeType = "type"

            // 如果是图片类型的文件消息，可配置缩略图，最多 3 个
            let thumbnailParams = ThumbnailCreateParams()
            thumbnailParams.maxSize = CGSize(width: 100, height: 100)
            thumbnailParams.fileURL = "https://example.com/example_thumbnail.png" // 发送第三方文件远端 URL 时，可设置
            params.thumbnails = [thumbnailParams]
            if (metionTypeString != nil) {
                if metionTypeString == "0" {
                    params.mentionType = .users
                }
                else {
                    params.mentionType = .channel
                }
                params.mentionedUserIds = metionUserIdsString?.components(separatedBy: ",")
                params.mentionedMessage = metionMessageString
                UatLogPannel.log("发送文件消息设置 @ 参数")
            }
            switch getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) {
            case "1":
                MethodCenter.shared.openChannel!.sendFileMessage(params: params) { (fileMsg: FileMessage?) in
                    // The body of the message being sent
                    UatLogPannel.log("Gro 发送文件消息 The body of the message being sent")
                } progressHandler: { (fileMsg: FileMessage?, progress: Int) in
                    // Handle sending progress, because file messages need to be uploaded.
                    UatLogPannel.log("Gro 发送文件消息进度  \(progress)" )
                } completionHandler: { (fileMsg: FileMessage?, error: ChatError?) in
                    if let e = error {
                        UatLogPannel.log("Gro 发送文件消息 " + e.description)
                        return
                    }
                    UatLogPannel.log("Gro 发送文件消息  " + fileMsg!.messageUId)
                    MethodCenter.shared.message = fileMsg;
                }
            default:
                MethodCenter.shared.subChannel!.sendFileMessage(params: params) { (fileMsg: FileMessage?) in
                    // The body of the message being sent
                    UatLogPannel.log("Gro 发送文件消息 The body of the message being sent")
                } progressHandler: { (fileMsg: FileMessage?, progress: Int) in
                    // Handle sending progress, because file messages need to be uploaded.
                    UatLogPannel.log("Gro 发送文件消息进度  \(progress)" )
                } completionHandler: { (fileMsg: FileMessage?, error: ChatError?) in
                    if let e = error {
                        UatLogPannel.log("Gro 发送文件消息 " + e.description)
                        return
                    }
                    UatLogPannel.log("Gro 发送文件消息  " + fileMsg!.messageUId)
                    MethodCenter.shared.message = fileMsg;
                }
            }
        }
    }

    /// 双向删除消息
    @objc static func deleteMessage(_ paramsString: String){
        switch getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) {
        case "1":
            MethodCenter.shared.openChannel?.deleteMessage(MethodCenter.shared.message!) { (error: ChatError?) in
                if let e = error {
                    UatLogPannel.log("openChannel 双向删除消息 " + e.debugDescription + MethodCenter.shared.message!.messageUId)
                    return
                }
                UatLogPannel.log("openChannel 删除消息成功 " + MethodCenter.shared.message!.messageUId)
            }
        default:
            MethodCenter.shared.subChannel?.deleteMessage(MethodCenter.shared.message!) { (error: ChatError?) in
                if let e = error {
                    UatLogPannel.log("subChannel 双向删除消息 " + e.debugDescription + MethodCenter.shared.message!.messageUId)
                    return
                }
                UatLogPannel.log("subChannel 删除消息成功 " + MethodCenter.shared.message!.messageUId)
            }
        }
    }
    
    /// 更新消息
    @objc static func updateMessage(_ paramsString: String){
        guard let message = MethodCenter.shared.message else {
              UatLogPannel.log("无法更新消息，message 为 nil")
              return
        }
        if MethodCenter.shared.message is TextMessage {
            let params = TextMessageUpdateParams()
            params.content = "new message update"
            MethodCenter.shared.subChannel?.updateTextMessage(MethodCenter.shared.message as! TextMessage, params: params) { error in
                if let e = error {
                    UatLogPannel.log("更新文本消息 " + e.debugDescription)
                    return
                }
                UatLogPannel.log("更新文本消息回调成功 ")
            }
        }
        else if MethodCenter.shared.message is FileMessage {

        }
        else if MethodCenter.shared.message is CustomMessage {

        }
    }
    
    /// 根据关键字查找消息
    @objc static func searchMessagesByKeyword(_ paramsString: String){
        UatLogPannel.log("根据关键字查找消息 " + paramsString)
        let params = MessageSearchQueryParams(keyword: paramsString)
        params.limit = 20
        params.messageTimestampFrom = 1732036166000
        params.messageTimestampTo = Int64(Int(Date().timeIntervalSince1970)) * 1000

        params.isQueryAllSubchannels = true

        let query = MethodCenter.shared.groupChannel!.createMessageSearchQuery(params: params)

        query.loadNextPage { messages, error in
            if let e = error {
                UatLogPannel.log("根据关键字查找消息 " + e.debugDescription)
                return
            }
            if let count = messages?.count, count == 0 {
                UatLogPannel.log("获取消息列表为空")
                return
            }
            messages!.forEach { message in
                UatLogPannel.log(
                    "消息列表 UID: \(message.messageUId)" + " 消息类型: \(message.mentionType)"
                )
            }
        }
    }
    
    /// 根据 userID 查找消息
    @objc static func searchMessagesByUserID(_ paramsString: String){
        UatLogPannel.log("根据 userID 查找消息 " + paramsString)
        let params = UserMessageListQueryParams(senderUserId: paramsString)
        params.messageTimestampTo = Int64(Int(Date().timeIntervalSince1970)) * 1000
        params.limit = 20
        params.isQueryAllSubchannels = true

        let query = MethodCenter.shared.groupChannel!.createUserMessageListQuery(params: params)

        query.loadNextPage { messages, error in
            if let e = error {
                UatLogPannel.log("根据 userID 查找消息 " + e.debugDescription)
                return
            }
            if let count = messages?.count, count == 0 {
                UatLogPannel.log("获取消息列表为空")
                return
            }
            messages!.forEach { message in
                UatLogPannel.log(
                    "消息列表 UID: \(message.messageUId)" + " 消息类型: \(message.mentionType)"
                )
            }
        }
    }
    
    /// 获取消息列表
    @objc static func getMessgesList(_ paramsString: String){
        UatLogPannel.log("获取消息列表   " + paramsString)
        let params = PreviousMessageListQueryParams()
        let queryTypeValue = MethodCenter.convertToUInt(from: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0)!)
        switch queryTypeValue {
        case 0:
            params.queryType = .local
        case 1:
            params.queryType = .remote
        case 2:
            params.queryType = .mix
        default:
            params.queryType = .mix
        }
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        params.messageTimestampTo = Int64(MethodCenter.convertToUInt(from: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1) ?? "\(currentTimestamp)"))
        params.limit = MethodCenter.convertToUInt(from: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 2) ?? "5")
        params.reverse = false

        let messageListQuery = MethodCenter.shared.subChannel!.createPreviousMessageListQuery(params: params)
        messageListQuery.loadNextPage { (messages: [BaseMessage]?, error: ChatError?) in
            if let e = error {
                UatLogPannel.log("获取消息列表 " + e.debugDescription)
                return
            }
            if let count = messages?.count, count == 0 {
                UatLogPannel.log("获取消息列表为空")
                return
            }
            messages!.forEach { message in
                UatLogPannel.log(
                    "消息列表 UID: \(message.messageUId)" + " 消息类型: \(message.mentionType)" + " 消息发送时间: \(message.createdAt)"
                )
            }
            MethodCenter.shared.message = messages?.first;
        }
    }
}

// MARK: - GroupChannel
extension MethodCenter {
    
    /// 创建 groupChannel
    @objc static func groupChannelCreate(_ paramsString: String){
        UatLogPannel.log("创建 groupChannel   " + paramsString)
        let params = GroupChannelCreateParams(id: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) ?? "", name: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1) ?? "")
        params.isSuper = getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 2) == "1"
        params.defaultSubchannelName = getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 3)
        
        GroupChannel.create(params: params) { (channel: GroupChannel?, error: ChatError?) in
            guard error == nil else {
                // Handle error.
                UatLogPannel.log("创建 groupChannel" + error.debugDescription)
                return
            }
            MethodCenter.shared.groupChannel = channel
            UatLogPannel.log(
                "创建 groupChannel" +
                " 是否超级: \(channel!.isSuper)" +
                " 参数未读消息: \(channel!.unreadMessageCount)" +
                " 参数未读提及: \(channel!.unreadMentionCount)"
            )
        }
    }
    
    /// 创建 groupSubchannel
    @objc static func groupSubchannelCreate(_ paramsString: String){
        UatLogPannel.log("创建 groupSubchannel   " + paramsString)
        let indexString = getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 2)
        let subchannelType: GroupSubchannelType = (indexString == "1") ? .private : .public
        let params = GroupSubchannelCreateParams(subchannelId: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) ?? "", subchannelName: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1) ?? "", subchannelType:subchannelType)

        MethodCenter.shared.groupChannel?.createSubchannel(params: params) { subchannel, error in
            if error != nil {
                UatLogPannel.log("创建 groupSubchannel" + error.debugDescription)
                return
            }
            MethodCenter.shared.subChannel = subchannel
            UatLogPannel.log(
                "创建 groupSubchannel" +
                " 是否私有: \(subchannel!.subchannelType)"
            )
        }
    }
    
    /// 更新 GroupChannel
    @objc static func updateGroupChannel(_ paramsString: String){
        UatLogPannel.log("更新 GroupChannel " + paramsString)
        switch getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) {
        case "1":
            let params = GroupSubchannelUpdateParams(subchannelId: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 2) ?? "CMSYDefault", subchannelName: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1) ?? "default")

            MethodCenter.shared.groupChannel?.updateSubchannel(params: params) { (subchannel: GroupSubchannel?, error: ChatError?) in
                if let e = error {
                    UatLogPannel.log("更新 Subchannel " + e.description)
                    return
                }
                UatLogPannel.log("更新 Subchannel 成功 id:\(String(describing: subchannel?.id)) name: \(String(describing: subchannel?.name))")
            }
        default:
            let params = GroupChannelUpdateParams(name: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1) ?? "default")

            MethodCenter.shared.groupChannel?.update(params: params) { (channel: GroupChannel?, error: ChatError?) in
                if let e = error {
                    UatLogPannel.log("更新 GroupChannel " + e.description)
                    return
                }
                UatLogPannel.log("更新 GroupChannel 成功")
            }
        }
    }
    
    /// 获取频道
    @objc static func getGroupChannel(_ paramsString: String){
        UatLogPannel.log("获取 groupChannel   " + paramsString)
        GroupChannel.getChannel(id: paramsString) { groupChannel, error in
            if let e = error {
                // Handle error.
                UatLogPannel.log("获取 groupChannel" + e.debugDescription)
                return
            }
            guard let groupChannel = groupChannel else {
                UatLogPannel.log("获取 groupChannel 失败，未能找到频道")
                return
            }
            MethodCenter.shared.groupChannel = groupChannel
            UatLogPannel.log(
                "获取 groupChannel" +
                " 是否超级: \(groupChannel.isSuper)" +
                " 参数未读消息: \(groupChannel.unreadMessageCount)" +
                " 参数未读提及: \(groupChannel.unreadMentionCount)"
            )
        }
    }
    
    /// 邀请用户
    @objc static func inviteMember(_ paramsString: String){
        let userIds = paramsString.components(separatedBy: ";")
        let params = GroupChannelInvitationParams(userIds: userIds)
        UatLogPannel.log("邀请成员   " + paramsString)
        MethodCenter.shared.groupChannel?.invite(params: params, completionHandler: { error, failedUserIds in
            if let e = error {
                // Handle error.
                UatLogPannel.log("邀请成员 " + e.debugDescription)
                if failedUserIds?.count == 0 {
                    // Handle failedUserIds
                    UatLogPannel.log("邀请成员失败 " + (failedUserIds!.joined(separator: "-")))
                }
                return
            }
            // Invited successfully
            UatLogPannel.log("邀请成员成功 " + (userIds.joined(separator: "-")))
        })
    }
    
    /// 主动加入 GroupChannel
    @objc static func joinGroupChannel(_ paramsString: String){
        UatLogPannel.log("主动加入 GroupChannel " + paramsString)
        MethodCenter.shared.groupChannel?.join(completionHandler: { error in
            if let e = error {
                UatLogPannel.log("主动加入 GroupChannel 失败" + e.description)
                return
            }
        UatLogPannel.log("主动加入 GroupChannel " + paramsString)
        })
    }
    
    /// 主动离开 GroupChannel
    @objc static func leaveGroupChannel(_ paramsString: String){
        UatLogPannel.log("主动离开 GroupChannel " + paramsString)
        MethodCenter.shared.groupChannel?.leave{(error: ChatError?) in
            if let e = error {
                UatLogPannel.log("主动离开 GroupChannel 失败" + e.description)
                return
            }
            UatLogPannel.log("主动离开 GroupChannel 成功")
        }
    }
    
    /// 添加或删除 subchannel 成员
    @objc static func addOrRemoveMembers(_ paramsString: String){
        let userIds = getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1)?.components(separatedBy: ",") ?? []
        switch getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) {
        case "1":
            UatLogPannel.log("删除 subchannel 成员" + paramsString)
            MethodCenter.shared.subChannel?.removeMembers(userIds: userIds, completionHandler: { error in
                if let e = error {
                    UatLogPannel.log("删除 subchannel 成员 " + e.description)
                    return
                }
            UatLogPannel.log("删除 subchannel 成员 ")
            })
        default:
            UatLogPannel.log("添加 subchannel 成员" + paramsString)
            MethodCenter.shared.subChannel?.addMembers(userIds: userIds) { subchannel, error in
                if let e = error {
                    UatLogPannel.log("添加 subchannel 成员 " + e.description)
                    return
                }

                UatLogPannel.log("添加 subchannel 成员" + (subchannel?.id ?? ""))
            }
        }
    }
    
    /// 获取 GroupChannel 成员列表
    @objc static func getGroupChannelUserLists(_ paramsString: String){
        UatLogPannel.log("获取 GroupChannel 成员列表 " + paramsString)
        switch getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) {
        case "1":
            let params = GroupSubchannelMemberListQueryParams()
            params.limit = MethodCenter.convertToUInt(from: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1) ?? "5")
            let memberListQuery = MethodCenter.shared.subChannel!.createMemberListQuery(params: params)
            memberListQuery.loadNextPage { totalCount, members, error in
                if let e = error {
                    UatLogPannel.log("获取 subChannel 成员列表 " + e.description)
                    return
                }
                if let membersCount = members?.count, membersCount == 0 {
                    UatLogPannel.log("subChannel 用户列表为空")
                    return
                }
                members!.forEach { member in
                    UatLogPannel.log("subChannel 用户 id: \(member.id)")
                }
            }
        default:
            let params = GroupChannelMemberListQueryParams()
            params.limit = MethodCenter.convertToUInt(from: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1) ?? "5")
            let memberListQuery = MethodCenter.shared.groupChannel!.createMemberListQuery(params: params)
            memberListQuery.loadNextPage { totalCount, members, error in
                if let e = error {
                    UatLogPannel.log("获取 groupChannel 成员列表 " + e.description)
                    return
                }
                if let membersCount = members?.count, membersCount == 0 {
                    UatLogPannel.log("groupChannel 用户列表为空")
                    return
                }
                members!.forEach { member in
                    UatLogPannel.log("groupChannel 用户 id: \(member.id)")
                }
            }
        }
    }

    /// 删除 GroupChannel
    @objc static func deleteGroupChannel(_ paramsString: String){
        UatLogPannel.log("删除 GroupChannel " + paramsString)
        switch getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) {
        case "1":
            MethodCenter.shared.groupChannel!.deleteSubchannel(id: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1) ?? "") { (error: ChatError?) in
                if let e = error {
                    UatLogPannel.log("删除 Subchannel " + e.description)
                    return
                }
                UatLogPannel.log("删除 Subchannel 成功")
            }
        default:
            MethodCenter.shared.groupChannel!.delete() { (error: ChatError?) in
                if let e = error {
                    UatLogPannel.log("删除 GroupChannel " + e.description)
                    return
                }
                UatLogPannel.log("删除 GroupChannel 成功")
            }
        }
    }
    
    /// 获取 subchannel
    @objc static func getSubchannelWithchannelId(_ paramsString: String){
        UatLogPannel.log("获取 subchannel " + paramsString)
        MethodCenter.shared.groupChannel!.getSubchannel( id: paramsString.isEmpty ? "CMSYDefault" : paramsString) { (result, error) in
            if let error = error {
                UatLogPannel.log("获取 subchannel " + error.debugDescription)
            } else if let subchannel = result {
                MethodCenter.shared.subChannel = subchannel
                UatLogPannel.log(
                    "获取 subchannel" + " id: \(subchannel.id)"
                )
            }
        }
    }
    
    /// 获取 groupchannel 未读数
    @objc static func getUnreadMessageCount(_ paramsString: String){
        let isMentioned = getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1) == "1"
        switch getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) {
        case "0":
            let params = GroupChannelUnreadMessageCountParams()
            params.isMentionedOnly = isMentioned

            GroupChannel.getTotalUnreadMessageCount(params: params) { (unreadCount: Int, error: ChatError?) in
                if let e = error {
                    UatLogPannel.log("获取 GroupChannel 未读数" + e.debugDescription)
                }
                UatLogPannel.log("获取 GroupChannel 未读数:  \(unreadCount)")
            }
        case "1":
            let params = GroupChannelUnreadMessageCountParams()
            params.isMentionedOnly = isMentioned

            MethodCenter.shared.groupChannel?.getUnreadMessageCount(params: params) { (unreadCount: Int, error: ChatError?) in
                if let e = error {
                    UatLogPannel.log("获取 groupChannel 未读数" + e.debugDescription)
                }
                UatLogPannel.log("获取 groupChannel 未读数:  \(unreadCount)" + "groupChannelID:  \(MethodCenter.shared.groupChannel?.id ?? "")")
            }
        case "2":
            let params = GroupSubchannelUnreadMessageCountParams()
            params.isMentionedOnly = isMentioned

            MethodCenter.shared.subChannel?.getUnreadMessageCount(params: params) { (unreadCount: Int, error: ChatError?) in
                if let e = error {
                    UatLogPannel.log("获取 subchannel 未读数" + e.debugDescription)
                }
                UatLogPannel.log("获取 subchannel 未读数:  \(unreadCount)" + "groupChannelID:  \(MethodCenter.shared.subChannel?.id ?? "")")            }
            
        default:
            let params = GroupChannelUnreadMessageCountParams()
            params.isMentionedOnly = isMentioned

            GroupChannel.getTotalUnreadMessageCount(params: params) { (unreadCount: Int, error: ChatError?) in
                if let e = error {
                    UatLogPannel.log("获取 GroupChannel 未读数" + e.debugDescription)
                }
                UatLogPannel.log("获取 GroupChannel 未读数:  \(unreadCount)")
            }
        }
    }
    
    
    /// 获取频道列表
    @objc static func getGroupChannelList(_ paramsString: String){
        UatLogPannel.log("获取 groupChannelList   " + paramsString)
        let params = GroupChannelListQueryParams()
        
        let limitValue = MethodCenter.convertToUInt(from: paramsString.components(separatedBy: ";").first!)
        params.limit = (limitValue == 0) ? 20 : limitValue
        
        let isUnreadOnlyValue = MethodCenter.convertToUInt(from: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1) ?? "0")
        params.isUnreadOnly = (((isUnreadOnlyValue == 0) ? 0 : 1) != 0)

        let orderTypeValue = MethodCenter.convertToUInt(from: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 2) ?? "0")
        if orderTypeValue == 1 {
            params.orderType = .lastTime
        } else {
            params.orderType = .joinTime
        }

        let query = GroupChannel.createMyGroupChannelListQuery(params: params)
        query.loadNextPage { channels, error in
            if let e = error {
                UatLogPannel.log("获取 groupChannelList" + e.debugDescription)
                return
            }
            if let count = channels?.count, count == 0 {
                UatLogPannel.log("获取 groupChannelList 为空")
                return
            }
            channels!.forEach { channel in
                UatLogPannel.log(
                    "获取到的 groupChannelList: \(channel.id)" + " 未读: \(channel.unreadMessageCount) " + " 最后消息: \(channel.lastMessage?.messageUId ?? "") "
                )
            }
        }
    }
    
    /// 获取 Subchannel 列表
    @objc static func getGroupSubchannelList(_ paramsString: String){
        UatLogPannel.log("获取 subchannelList   " + paramsString)
        let params = GroupSubchannelListQueryParams()
        let isUnreadOnlyValue = MethodCenter.convertToUInt(from: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) ?? "0")
        params.isUnreadOnly = (((isUnreadOnlyValue == 0) ? 0 : 1) != 0)

        let subchannelType = MethodCenter.convertToUInt(from: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1) ?? "0")
        if subchannelType == 1 {
            params.subchannelTypeFilter = .public
        } else if subchannelType == 2{
            params.subchannelTypeFilter = .private
        } else {
            params.subchannelTypeFilter = .all
        }
        let query =  MethodCenter.shared.groupChannel!.createMyGroupSubchannelListQuery(params: params)
        query.loadNextPage { subchannels, error in
            if let e = error {
                UatLogPannel.log("获取 subchannelList" + e.debugDescription)
                return
            }

            if let count = subchannels?.count, count == 0 {
                UatLogPannel.log("获取 subchannelList 为空")
                return
            }
            subchannels!.forEach { subchannel in
                UatLogPannel.log(
                    "获取到的 subchannelList: \(subchannel.id)" +
                    " 未读: \(subchannel.unreadMessageCount)" +
                    " 未读@: \(subchannel.unreadMentionCount)" +
                    " 最后一条消息: \(subchannel.lastMessage?.messageUId ?? "无")"
                )
            }
        }
    }
    
    /// 设置 subchannel 免打扰
    @objc static func setSubchannelNotificationLevel(_ paramsString: String){
        UatLogPannel.log("设置 subchannel 免打扰 " + paramsString)
        guard let levelInt = Int(paramsString) else {
            UatLogPannel.log("无效的 paramsString: \(paramsString) 无法转换为整数")
            return
        }
        guard let level = PushNotificationLevel(rawValue: levelInt) else {
            UatLogPannel.log("无效的通知级别: \(levelInt)，无法设置对应的 PushNotificationLevel")
            return
        }
        MethodCenter.shared.subChannel!.setMyNotificationLevel(level) { error in
            if let e = error {
                UatLogPannel.log("设置 subchannel 免打扰 " + e.debugDescription)
                return
            }
            UatLogPannel.log("设置 subchannel 免打扰成功")
        }
    }
    
    /// 获取 subchannel 免打扰
    @objc static func getSubchannelNotificationLevel(_ subChannel: GroupSubchannel?){
        let subChannel = subChannel ?? MethodCenter.shared.subChannel
        UatLogPannel.log("获取 subchannel 免打扰" + subChannel!.id)
        subChannel!.getMyNotificationLevel { level, error in
            if let e = error {
                UatLogPannel.log("获取 subchannel 免打扰失败 " + e.debugDescription)
                return
            }
            UatLogPannel.log("获取 subchannel 免打扰成功级别: \(level) id:" + subChannel!.id)
        }
    }
    
    /// 标记 subchannel 已读
    @objc static func cleanUnreadMessages(_ paramsString: String){
        UatLogPannel.log("标记 subchannel 已读")
        MethodCenter.shared.subChannel?.markAsRead() { (error: ChatError?) in
            if let e = error {
                UatLogPannel.log("标记 subchannel 已读 " + e.debugDescription)
                return
            }
            UatLogPannel.log("标记 subchannel 已读 成功" + MethodCenter.shared.subChannel!.id)
            // Handle the message that has been successfully read
        }
    }

}

// MARK: - OpenChannel
extension MethodCenter {
    /// 创建 openChannel
    @objc static func openChannelCreate(_ paramsString: String){
        UatLogPannel.log("创建 openChannel   " + paramsString)
        let params = OpenChannelCreateParams(id: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) ?? "", name: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1) ?? "")
        switch getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 2) {
        case "1":
            params.destroyType = .timed
        default:
            params.destroyType = .auto
        }
        params.survivalTime = Int(convertToUInt(from: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 3) ?? "0", defaultValue: 0))
        
        OpenChannel.create(params: params) { channel, error in
            guard error == nil else {
                UatLogPannel.log("创建 openChannel" + error.debugDescription)
                return
            }
            MethodCenter.shared.openChannel = channel
            UatLogPannel.log(
                "创建 openChannel" +
                " id: \(String(describing: channel?.id))"
            )
        }
    }
    
    /// 更新 openChannel
    @objc static func openChannelUpdate(_ paramsString: String){
        UatLogPannel.log("更新 openChannel   " + paramsString)
        let params = OpenChannelUpdateParams()
        params.name = getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) ?? ""
        switch getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1) {
        case "1":
            params.destroyType = .timed
        default:
            params.destroyType = .auto
        }
        params.survivalTime = Int(convertToUInt(from: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 2) ?? "0", defaultValue: 0))
        
        MethodCenter.shared.openChannel?.update(params: params) { channel, error in
            guard error == nil else {
                UatLogPannel.log("更新 openChannel" + error.debugDescription)
                return
            }
            MethodCenter.shared.openChannel = channel
            UatLogPannel.log(
                "更新 openChannel" +
                " id: \(String(describing: channel?.id))"
            )
        }
    }
    
    /// 获取 openChannel
    @objc static func openChannelGet(_ paramsString: String){
        UatLogPannel.log("获取 openChannel   " + paramsString)
        OpenChannel.getChannel(id: paramsString) { channel, error in
            if let e = error {
                UatLogPannel.log("更新 openChannel" + e.debugDescription)
                return
            }
            MethodCenter.shared.openChannel = channel
            UatLogPannel.log(
                "获取 openChannel" +
                " id: \(String(describing: channel?.id))"
            )
        }
    }
    
    /// 加入 openChannel
    @objc static func openChannelEnter(_ paramsString: String){
        UatLogPannel.log("加入 openChannel   " + paramsString)
        MethodCenter.shared.openChannel?.enter { error in
            if let e = error {
                UatLogPannel.log("加入 openChannel" + e.debugDescription)
                return
            }
            UatLogPannel.log(
                "加入 openChannel 成功"
            )
        }
    }
    
    /// 离开 openChannel
    @objc static func openChannelExit(_ paramsString: String){
        UatLogPannel.log("离开 openChannel   " + paramsString)
        MethodCenter.shared.openChannel?.exit { (error: ChatError?) in
            if let e = error {
                UatLogPannel.log("离开 openChannel" + e.debugDescription)
                return
            }
            UatLogPannel.log("离开 openChannel 成功")
        }
    }
    
    /// 获取 openChannel 属性
    @objc static func openChannelMetadataGet(_ paramsString: String){
        UatLogPannel.log("获取 openChannel 属性   " + paramsString)
        switch getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) {
        case "1":
            MethodCenter.shared.openChannel?.getAllMetadata() { metadata, error in
                if let e = error {
                    UatLogPannel.log("获取 openChannel 属性" + e.debugDescription)
                    return
                }
                UatLogPannel.log("获取 openChannel 属性 key" + (metadata?.keys.joined(separator: ",") ?? "")  + "value" + (metadata?.values.joined(separator: ",") ?? "") )
            }
        default:
            let partString = getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 1)
            let splitKeys = partString?.split(separator: ",") ?? []
            let keys = splitKeys.map { String($0) } 

            MethodCenter.shared.openChannel?.getMetadata(keys: keys) { metadata, error in
                if let e = error {
                    UatLogPannel.log("获取 openChannel 属性" + e.debugDescription)
                    return
                }
                UatLogPannel.log("获取 openChannel 属性 key" + (metadata?.keys.joined(separator: ",") ?? "")  + "value" + (metadata?.values.joined(separator: ",") ?? "") )
            }
        }
    }
    
    /// 设置 openChannel 属性
    @objc static func openChannelMetadataSet(_ paramsString: String){
        UatLogPannel.log("设置 openChannel 属性   " + paramsString)
        var metadata = [String: String]()
        let pairs = paramsString.split(separator: ",")
        for pair in pairs {
            let keyValue = pair.split(separator: ":")
            if keyValue.count == 2 {
                let key = String(keyValue[0])
                let value = String(keyValue[1])
                metadata[key] = value
            }
        }
        let params = OpenChannelMetadataSetParams(metadata: metadata)

        MethodCenter.shared.openChannel?.setMetadata(params: params, completionHandler: { error in
            if let e = error {
                UatLogPannel.log("设置 openChannel 属性" + e.debugDescription)
                return
            }
            UatLogPannel.log("设置 openChannel 属性成功")
        })
    }
    
    /// 获取 OpenChannel 成员列表
    @objc static func openChannelUserListsGet(_ paramsString: String){
        UatLogPannel.log("获取 OpenChannel 成员列表 " + paramsString)
        let params = OpenChannelMemberListQueryParams()
        params.limit = MethodCenter.convertToUInt(from: getElementAtIndex(from: paramsString.components(separatedBy: ";"), at: 0) ?? "5")
        params.reverse = false

        let memberListQuery = MethodCenter.shared.openChannel?.createMemberListQuery(params: params)
        memberListQuery?.loadNextPage { (totalCount, members, error) in
            if let e = error {
                UatLogPannel.log("OpenChannel 获取成员列表 " + e.description)
                return
            }
            if let membersCount = members?.count, membersCount == 0 {
                UatLogPannel.log("OpenChannel 用户列表为空")
                return
            }
            members!.forEach { member in
                UatLogPannel.log("OpenChannel 用户 id: \(member.id)")
            }
        }
    }
    
}

// MARK: - BaseChannelDelegate
extension MethodCenter: BaseChannelDelegate {
    /// 设置 Channel 代理
    @objc static func addChannelDelegate(_ paramsString: String) {
        UatLogPannel.log("设置 Channel 代理 ")
        CommsayChat.addChannelDelegate(MethodCenter.shared, identifier:"MethodCenter")
        CommsayChat.addConnectionDelegate(MethodCenter.shared, identifier: "MethodCenter")
    }
    func channelWasCreated(_ channel: BaseChannel) {
        UatLogPannel.log("创建 channel: \(channel.id) name:" + (channel.name ?? ""))
    }
        
    func channelWasUpdated(_ channel: BaseChannel) {
        UatLogPannel.log("更新 channel: \(channel.id) name:" + (channel.name ?? ""))
    }
        
    func channelWasDeleted(_ channel: BaseChannel) {
        UatLogPannel.log("删除 channel: \(channel.id) name:" + (channel.name ?? ""))
    }

    func channel(_ channel: BaseChannel, usersWasBanned users: [BanRestrictionUser]) {
        for user in users {
            if user.id == MethodCenter.shared.currentUser?.id {
                UatLogPannel.log("您已经被封禁" )
            }
            else {
                UatLogPannel.log("封禁用户:" + user.id)
            }
        }
    }

    func channel(_ channel: BaseChannel, usersWasUnbanned users: [BanRestrictionUser]) {
        for user in users {
            if user.id == MethodCenter.shared.currentUser?.id {
                UatLogPannel.log("您已经被解除封禁" )
            }
            else {
                UatLogPannel.log("解除封禁用户:" + user.id)
            }
        }
    }

    func channel(_ channel: BaseChannel, usersWasMuted users: [MuteRestrictionUser]) {
        for user in users {
            if user.id == MethodCenter.shared.currentUser?.id {
                UatLogPannel.log("您已经被禁言" )
            }
            else {
                UatLogPannel.log("禁言用户:" + user.id)
            }
        }
    }

    func channel(_ channel: BaseChannel, usersWasUnmuted users: [MuteRestrictionUser]) {
        for user in users {
            if user.id == MethodCenter.shared.currentUser?.id {
                UatLogPannel.log("您已经被解除禁言" )
            }
            else {
                UatLogPannel.log("解除禁言用户:" + user.id)
            }
        }
    }

    func channelWasFrozen(_ channel: BaseChannel) {
        UatLogPannel.log("冻结 channel: " + channel.id)
    }

    func channelWasUnfrozen(_ channel: BaseChannel) {
        UatLogPannel.log("解除冻结 channel: " + channel.id)
    }

    func channel(_ channel: BaseChannel, usersWasAddToAllowlist users: [FrozeAllowUser]) {
        for user in users {
            if user.id == MethodCenter.shared.currentUser?.id {
                UatLogPannel.log("您已经被加入冻结白名单" )
            }
            else {
                UatLogPannel.log("加入冻结白名单:" + user.id)
            }
        }
    }

    func channel(_ channel: BaseChannel, usersWasRemoveFromAllowlist users: [FrozeAllowUser]) {
        for user in users {
            if user.id == MethodCenter.shared.currentUser?.id {
                UatLogPannel.log("已经被移除冻结白名单" )
            }
            else {
                UatLogPannel.log("移出冻结白名单:" + user.id)
            }
        }
    }
}

// MARK: -  GroupChannelDelegate
extension MethodCenter: GroupChannelDelegate {
    func channelDidSync() {
        UatLogPannel.log("GroupChannel 同步完毕")
    }
    
    func channel(_ channel: GroupChannel, usersDidJoin info: GroupChannelMemberJoinInfo) {
        UatLogPannel.log("监听用户加入 Channel: \(info.members)")
    }
    
    func channel(_ channel: GroupChannel, usersDidLeave users: [GroupChannelMember]) {
        UatLogPannel.log("监听用户离开 GroupChannel: " + users.first!.id)
    }
}

// MARK: -  GroupSubchannelDelegate
extension MethodCenter: GroupSubchannelDelegate {
    
    func channel(_ channel: ConversationChannel, didReceive message: BaseMessage) {
        switch channel.channelType {
        case .subGroup:
            MethodCenter.getSubchannelNotificationLevel(channel as? GroupSubchannel);
        default: break
            
        }
        if message is TextMessage {
            let textMsg = message as! TextMessage
            UatLogPannel.log(
                "收到文本消息的 Subchannel: \(channel.id)" + " messageUID: \(message.messageUId) 内容" + textMsg.content
            )
        }
        else if message is FileMessage {
            UatLogPannel.log(
                "收到文件消息的 Subchannel: \(channel.id)" + " messageUID: \(message.messageUId)"
            )
        }
        else if message is CustomMessage {
            UatLogPannel.log(
                "收到自定义消息的 Subchannel: \(channel.id)" + " messageUID: \(message.messageUId)"
            )
        }
    }
    
    func channel(_ channel: ConversationChannel, didDelete message: BaseMessage) {
        UatLogPannel.log(
            "删除消息的 channel: \(channel.id)" + " 删除的消息: \(message.messageUId)"
        )
    }
    
    func channel(_ channel: GroupSubchannel, didUpdate message: BaseMessage) {
        if message is TextMessage {
            let textMsg = message as! TextMessage
            UatLogPannel.log(
                "更新消息的 channel: \(channel.id)" + " 更新的消息: \(message.messageUId)" + "已修改: \(message.isModified) 内容:" + textMsg.content
            )
        } else {
            UatLogPannel.log(
                "更新消息的 channel: \(channel.id)" + " 更新的消息: \(message.messageUId)" + "已修改: \(message.isModified)"
            )
        }
    }
    func channel(_ channel: ConversationChannel, didBlock message: BaseMessage, reviewInfo: MessageReviewInfo) {
            UatLogPannel.log(
                "拦截消息的 channel: \(channel.id)" + " 拦截的消息: \(message.messageUId)"
            )
    }
    func channel(_ channel: GroupSubchannel, didUpdateTypingStatus users: [TypingUser]) {
        
    }
              
    func channel(channel: GroupSubchannel, didUpdateReadStatus digest: ReadStatusDigest) {
        UatLogPannel.log(
            "已读状态更新 channel: \(channel.id) + \(digest.messageUId)"
        )
    }
       
    func channel(_ channel: GroupSubchannel, didAddMembers members: [GroupChannelMember]) {
        UatLogPannel.log("监听添加用户 Subchannel: " + members.first!.id)
    }
       
    func channel(_ channel: GroupSubchannel, didRemoveMembers members: [GroupChannelMember]) {
        UatLogPannel.log("监听移除用户 Subchannel: " + members.first!.id)
    }
    
    func channelDidUpdateReadStatus(_ channel: GroupSubchannel) {
        UatLogPannel.log("更新已读 Subchannel: " + channel.id)
    }

}

// MARK: -  OpenChannelDelegate
extension MethodCenter: OpenChannelDelegate {
    
    func channelDidChangeParticipantCount(_ channel: OpenChannel) {
        UatLogPannel.log("OpenChannel 成员数量 " + "\(channel.participantCount)")
    }
    
    func channel(_ channel: OpenChannel, usersDidEnter members: [OpenChannelMember]) {
        UatLogPannel.log("OpenChannel 成员加入 " + (members.first?.id ?? ""))
    }
    
    func channel(_ channel: OpenChannel, usersDidExit members: [OpenChannelMember]) {
        UatLogPannel.log("OpenChannel 成员退出 " + (members.first?.id ?? ""))
    }
    
    func channelDidSyncMetadata(_ channel: OpenChannel) {
        UatLogPannel.log("OpenChannel 同步属性完成 ")
    }
    
    func channel(_ channel: OpenChannel, updatedMetadata metaData: [String : String]) {
        for data in metaData {
            UatLogPannel.log("OpenChan 属性更新 id:\(channel.id)  \(data.key):\(data.value)")
        }
    }
    
    func channel(_ channel: OpenChannel, deletedMetadata keys: [String]) {
        for key in keys {
            UatLogPannel.log("OpenChan 属性删除 id:\(channel.id)  \(key)")
        }
    }
    
    func channel(_ channel: OpenChannel, reenterDidFail error: ChatError) {
        UatLogPannel.log("OpenChannel reenterDidFail " + ChatError.debugDescription())
    }
    
    func channelDidStartReenter(_ channel: OpenChannel) {
        UatLogPannel.log("OpenChannel channelDidStartReenter " + "\(channel.id)")
    }
        
    func channelDidSuccessReenter(_ channel: OpenChannel) {
        UatLogPannel.log("OpenChannel DidSuccessReenter " + "\(channel.id)")
    }
}

// MARK: -  ConnectionDelegate
extension MethodCenter {
    func connecting() {
        UatLogPannel.log("connecting")
    }

    func didConnect() {
        UatLogPannel.log("didConnect")
    }

    func didSuspend() {
        UatLogPannel.log("didSuspend" )
    }

    func didDisconnect(error: CommsayChatSDK.ChatError?) {
        UatLogPannel.log("didDisconnect")
    }
}

// MARK: -  ConversationChannelDelegate
extension MethodCenter: ConversationChannelDelegate {
  
}



