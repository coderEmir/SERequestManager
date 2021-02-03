//
//  UploadManager.swift
//  SERequestManager
//
//  Created by wenchang on 2021/1/27.
//


import AliyunOSSiOS

public enum ImageQuilityType {
    case nomal
    case compress
}

public class UploadManager {
    
    public static func shared() -> UploadManager {
        
        let instance = UploadManager()
        return instance
    }

    public static func createCredential(with credential: CredentialModel?) -> OSSClient? {

        guard let credential = credential else { return nil }
        let credentialProvider = OSSStsTokenCredentialProvider(accessKeyId: credential.keyId!, secretKeyId: credential.keySecret!, securityToken: credential.securityToken!)
        
        let clientConfig = OSSClientConfiguration()
        clientConfig.maxRetryCount = 3; // 网络请求遇到异常失败后的重试次数
        clientConfig.timeoutIntervalForRequest = 30; // 网络请求的超时时间
        clientConfig.timeoutIntervalForResource = 24 * 60 * 60; // 允许资源传输的最长时间
        
        return OSSClient(endpoint: credential.endPoint!, credentialProvider: credentialProvider, clientConfiguration: clientConfig)
    }
    
    public static func uploadImages(_ images: [UIImage?], client: OSSClient, imageQuility: ImageQuilityType = .compress, bucketName: String, documentPath: String = "", success:@escaping ((_ json: [String])->()),failure:@escaping ((String)->()))
    {
        guard images.count > 0 else {
            failure("上传失败")
            return
        }
        
        var imageData: Data?
        var imagePaths: [String] = []
        var imageIndex = 0
        
        DispatchQueue.global().async {
            images.forEach { image in
                // 图片压缩
                switch imageQuility {
                    case .compress:
                        imageData = image?.resetSizeOfImage(maxSize: 100)
                    case .nomal:
                        imageData = (image?.jpegData(compressionQuality: 1.0) ?? Data())
                }
                guard let imageData = imageData else {
                    failure("上传失败")
                    return
                }
                
                let put = OSSPutObjectRequest()
                put.bucketName = bucketName
                put.uploadingData = imageData
                
                let num = (arc4random() % 1000)
                
                put.objectKey = "\(documentPath)/iOS\(Date().currentTime)\(imageIndex)\(num).jpg"
                
                let putTask = client.putObject(put)
                putTask.continue({(task: OSSTask<AnyObject>) -> Any? in
                    let ossPath = client.endpoint.components(separatedBy: "//").last!
                    print(ossPath,put.objectKey)
                    imagePaths.append("https://\(put.bucketName).\(ossPath)/\(put.objectKey)")
                    print(imagePaths)
                    if task.error != nil {
                        failure("上传失败")
                        return nil
                    }
                    imagePaths.append("https://\(put.bucketName).\(ossPath)/\(put.objectKey)")
                    if imageIndex == images.count - 1 {
                        DispatchQueue.main.async {
                            success(imagePaths)
                        }
                    }
                    imageIndex += 1
                    return nil
                })
                
                putTask.waitUntilFinished()
            }
        }
        
    }
}

fileprivate extension Date {
    var currentTime: String {
        let timeInterval: TimeInterval = NSTimeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
}

