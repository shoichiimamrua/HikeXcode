//
//  PostDispatcher.swift
//  HikeXcode
//
//  Created by 今村翔一 on 2015/12/03.
//  Copyright © 2015年 今村翔一. All rights reserved.
//

import Alamofire
import SwiftyJSON

class PostDispatcher {

    var postURL = "http://localhost:3000/post/create.json"
    var uploadURL = "http://localhost:3000/post/upload_process.json"
    //var params:[String:[String:AnyObject]] = [:]
    var params:[String:AnyObject] = [:]
    var post:Post?
    var fileURL = NSBundle.mainBundle().URLForResource("postBackImage", withExtension: "jpg")!
    
    init(post:Post){
        self.post = post
    }
    
    //画像以外をリクエスト
    func download(callback: (Bool) -> Void){
        if let id:Int = post?.id,
            let userName:String = post?.userName,
            let postContent:String = post?.postContent,
            let latitude:Double = post?.latitude,
            let longitude:Double = post?.longitude {
                self.params = [
                    "user":[
                        "id": id,
                        "username": userName],
                    "post":[
                        "text": postContent,
                        "latitude": latitude,
                        "longitude": longitude]
                ]
                
                Alamofire.request(.GET, postURL, parameters: params).responseJSON{_, _, result in
                    if result.isSuccess,
                        let res = result.value as? [String:AnyObject]{
                            print("投稿確認：\(res["result"]!.intValue)")
                            if res["result"]!.intValue == 1 {
                                callback(true)
                            } else {
                                callback(false)
                            }
                    }
                }
        }
    }

    //画像のアップロードと投稿情報のリクエストをする(成否は確認中)
    func upload(callback: (Bool) -> Void){
        
        if let postImage = post?.postImageURL {
                self.fileURL = NSBundle.mainBundle().URLForResource(String(postImage), withExtension: "jpg")!
        }
                
        Alamofire.upload(.POST, uploadURL, multipartFormData: { (multipartFormData) in
            //画像をアップロードする
            multipartFormData.appendBodyPart(fileURL: self.fileURL, name: "image")
            },
            //リクエストボディ生成のエンコード処理が完了したら呼ばれる
            encodingCompletion: { (encodingResult) in
                switch encodingResult {
                    //エンコード成功時
                    case .Success(let upload, _, _):
                        upload.responseJSON { _, _, result in
                            print(result)
                            callback(true)
                    }
                    //エンコード失敗時
                    case .Failure(let encodingError):
                        print(encodingError)
                        callback(false)
                    }
            })
    }
}
