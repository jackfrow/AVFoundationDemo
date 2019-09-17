//
//  VideoHelper.swift
//  AVFoundationDemo
//
//  Created by yy on 2019/9/16.
//  Copyright © 2019 Jackfrow. All rights reserved.
//

import UIKit
import Photos

class VideoHelper: NSObject {

    
     static func saveToAlbum(atURL url: URL){
      
      PHPhotoLibrary.shared().performChanges({
          PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
      }, completionHandler: { (success, error) in
          showSaveResult(isSuccess: success)
      })
  }
    
    static func showSaveResult(isSuccess: Bool) {
          let message = isSuccess ? "已保存到相册" : "保存失败"
          print("exportMessage = \(message)")
      
      }
    
     static func createTemplateFileURL() -> URL {
        
          let path = NSTemporaryDirectory() + "composition.mp4"
        
          print(path)
        
          let fileURL = URL(fileURLWithPath: path)
          if FileManager.default.fileExists(atPath: fileURL.path) {
              do { try FileManager.default.removeItem(at: fileURL) } catch {
                  
              }
          }
          return fileURL
      }
    
}
