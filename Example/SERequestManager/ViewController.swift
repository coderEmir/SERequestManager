//
//  ViewController.swift
//  SERequestManager
//
//  Created by 17629918 on 01/28/2021.
//  Copyright (c) 2021 17629918. All rights reserved.
//

import UIKit
import SERequestManager
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        request()
    }
    
    func request() {
        //MARK:  上传图片
        //MARK: NetworkManager get请求举例
        NetworkManager.startRequest { manager -> NetworkManager in
            manager.requestType(.get)
            .url("ossConfig")
            .origialData(origialData: { (jsonString, reponseData) in
                print("请求到的原始数据",jsonString as Any, reponseData)
            })
            .success { data in
                print("成功获取到success['data']的数据")
                
                //MARK: 解析举例：使用结构体模型的可选类型，作为参数
                let credential: CredentialModel? = SECodable.decoder(data: data)
                print(credential as Any)
                
                // MARK: UploadManager 阿里云oss图片上传举例
                guard let client = UploadManager.createCredential(with: credential) else { return }
                UploadManager.uploadImages([UIImage()], client: client, bucketName: "xxxx") { imagePaths in
                    print(imagePaths)
                    
                } failure: { code in
                    print(code)
                }

                
            }.failure { (code, msg) in
                print("错误码：\(code ?? 0)，错误信息：\(msg)")
            }
        }
    }
}

