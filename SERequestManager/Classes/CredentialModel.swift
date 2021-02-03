//
//  CredentialModel.swift
//  WCFMineModule
//
//  Created by wenchang on 2021/1/28.
//

import Foundation

/// 阿里云oss Credential 参数模型
public struct CredentialModel: Codable {
    var keyId: String? = ""
    var keySecret: String? = ""
    var securityToken: String? = ""
    var expirationTimeInGMTFormat: String? = ""
    var endPoint: String?
}
