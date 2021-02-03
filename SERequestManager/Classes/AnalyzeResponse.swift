//
//  AnalyzeResponse.swift
//  WCFMineModule
//
//  Created by wenchang on 2021/1/28.
//

import Foundation

// MARK: 字符串转字典
public extension String {
    
    func toDictionary() -> [String : Any] {
        
        var result = [String : Any]()
        guard !self.isEmpty else { return result }
        
        guard let dataSelf = self.data(using: .utf8) else {
            return result
        }
        
        if let dic = try? JSONSerialization.jsonObject(with: dataSelf,
                           options: .mutableContainers) as? [String : Any] {
            result = dic
        }
        return result
    }
}

// MARK: 字典转字符串
public extension Dictionary {
    
    func toJsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self,
                                                     options: []) else {
            return nil
        }
        guard let str = String(data: data, encoding: .utf8) else {
            return nil
        }
        return str
     }
}

public struct SECodable {

    public static func decoder<T: Codable>(data: Data) -> T? {
        let modelObject = try? JSONDecoder().decode(T.self, from: data)
        guard let model = modelObject else { return nil}
        return model
    }
    
    public static func encoder<T: Codable>(toDictionary model: T) -> [String : Any]? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(model) else { return nil }
        guard let jsonStr = String(data: data, encoding: .utf8) else { return nil }
        
        let parmas = jsonStr.toDictionary()
        return parmas
    }
}

