//
//  NetworkManager.swift
//  SERequestManager
//
//  Created by wenchang on 2021/1/27.
//

import Alamofire

public enum RequestType {
    case get
    case post
    case delete
    case put
}

public class NetworkManager {
    
    public typealias SuccessHandlerType = ((Data) -> Void)
    public typealias FailureHandlerType = ((_ errorCode: Int?,_ message: String) ->Void)
    public typealias OrigialDataBlockType = ((NSString?, Data) ->Void)
    
    private var requestType: HTTPMethod = .get//请求类型
    private var url: String?//URL
    private var params: [String: Any]?//参数
    var success: SuccessHandlerType?//成功的回调
    var origialDataBlock: OrigialDataBlockType?//请求结果的回调
    var failure: FailureHandlerType?//失败的回调
    private var httpRequest: Request?
    
    private var hostUrl: String?
    
    private var isOldHeaders: Bool = true
    
    private var headers: HTTPHeaders?
    
    fileprivate static func shared() -> NetworkManager {
        
        struct Static {
            static let instance = NetworkManager()
        }
        return Static.instance
    }
    
    //MARK:数据请求方法
    
    ///数据请求方法
    ///- Parameters:
    ///     - url    : 接口地址
    ///     - type   : 请求类型 get,post,delete,put
    ///     - params : 参数 [String : Any]
    ///     - success: 成功的回调
    ///     - failure: 失败的回调
   
    fileprivate func request(url: String,type:HTTPMethod,params:[String : Any]?, success: SuccessHandlerType?,failure: FailureHandlerType?){
        
        let encoding: ParameterEncoding = type == .post ? JSONEncoding.default: URLEncoding.default
        
        Alamofire.Session.default.request(url, method: requestType, parameters: params, encoding: encoding, headers: headers).responseJSON {[weak self] response in
        
            guard let resData = response.data else {
                failure?(404, "解析错误")
                return
            }
            
            guard let jsonData = try? (JSONSerialization.jsonObject(with: resData, options: .mutableContainers) as! [String: Any]) else {
                failure?(404, "解析错误")
                return
            }
            //MARK: 控制台预览请求结果
            let dataString = NSString(data:resData ,encoding: String.Encoding.utf8.rawValue)
            self?.origialDataBlock?(dataString, resData)
            
            if(((response.response?.statusCode)! > 199) && ((response.response?.statusCode)! < 300)) {
                
                switch response.result {
                    case .success:
                        
                        guard let successData = try? JSONSerialization.data(withJSONObject: jsonData["data"] as Any, options: .fragmentsAllowed) else {
                            failure?(404, "解析错误")
                            return
                        }
                        success?(successData)
                        
                    case .failure:
                        let statusCode = response.response?.statusCode
                        guard let resMessage = try? JSONSerialization.data(withJSONObject: jsonData["msg"] as Any, options: .fragmentsAllowed) else {
                            failure?(404, "解析错误")
                            return
                        }
                        guard let message = NSString(data:resMessage, encoding: String.Encoding.utf8.rawValue) else {
                            failure?(404, "解析错误")
                            return
                        }
                        failure?(statusCode, message as String)
                }
            }
        }
    }
}


// 链式调用设置
extension NetworkManager {
    ///设置url
    public func url(_ url: String?) -> Self {
        guard let hostUrl = hostUrl else {
            
            print("请配置host，例如，在appdelegate中设置 NetworkManager.shared().host('http://www.example.com/')")
            return self
        }
        self.url = hostUrl + (url ?? "")
        
        
        self.headers = isOldHeaders ? nil : self.headers
        if self.headers == nil {
            self.headers = HTTPHeaders(arrayLiteral: HTTPHeader(name: "content-type", value: "application/json"))
        }
        return self
    }
    
    ///设置请求类型 默认get
    public func requestType(_ type: RequestType) -> Self {
        switch type {
        case .get:
            self.requestType = .get
        case .post:
            self.requestType = .post
        case .delete:
            self.requestType = .delete
        case .put:
            self.requestType = .put
        }
        return self
    }
    
    public func addHeaders(_ headers: [HTTPHeader]) -> Self {
        isOldHeaders = false
        headers.forEach { header in
            self.headers?.add(header)
        }
        return self
    }
    
    ///设置参数
    public func params(_ params: [String: Any]?) -> Self {
        self.params = params
        return self
    }
    
    ///成功的回调
    public func success(_ handler: SuccessHandlerType?) -> Self {
        self.success = handler
        return self
    }
    
    ///失败的回调
    public func failure(handler: FailureHandlerType?) -> Self {
        self.failure = handler
        return self
    }
    
    public func origialData(origialData: OrigialDataBlockType?) -> Self {
        self.origialDataBlock = origialData
        return self
    }
    ///链式调用，确认所有参数后，最后调用，发起请求
    func request() -> Self {
        request(url: self.url!, type: self.requestType, params: self.params, success: self.success, failure: self.failure)
        return self
    }
    
    /// 闭包调用，私有函数
    fileprivate static func privateRequest(_ manager: NetworkManager) {
        manager.request(url: manager.url!, type: manager.requestType, params: manager.params, success: manager.success, failure: manager.failure)
    }
    
    
}

/// 暴露API
extension NetworkManager {
    /// 闭包请求方式
    public static func startRequest(_ manager: ((_ manager: NetworkManager) -> NetworkManager)) {
        
        privateRequest(manager(self.shared()))
    }
    
    public static func host(_ url: String) {
        NetworkManager.shared().hostUrl = url
    }
}
