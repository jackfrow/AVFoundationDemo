//
//  MergeViewController.swift
//  AVFoundationDemo
//
//  Created by yy on 2019/9/16.
//  Copyright © 2019 Jackfrow. All rights reserved.
//

import UIKit
import AVFoundation
import Photos


class MergeViewController: UIViewController {

     var videos: [AVAsset] = []
     let composition = AVMutableComposition()
     var player:AVPlayer!
     var playerLayer:AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        navigationItem.title = "视屏合成"

        //1.加载bundle中的视屏
        prepareResource()
        //2.构建视频轨道
        buildVideoTrack()
        //3.构建音频轨道
        buildVideoTrack()
        //4.播放最新的视屏
        playVideo()
        //5.导出视屏
        export()
    }

    func prepareResource()  {
    
        guard let urls =  Bundle.main.urls(forResourcesWithExtension: ".mp4", subdirectory: nil) else {
            return
        }
        
        
        for url  in urls {
            let asset = AVAsset(url: url)
            videos.append(asset)
        }
    
    }
    
   
    func buildVideoTrack()  {
        
        //使用invalid，系统会自动分配一个有效的trackId
        let trackId = kCMPersistentTrackID_Invalid
        
        guard let track = composition.addMutableTrack(withMediaType: .video, preferredTrackID: trackId) else {
            return
        }
        //视频片段插入时间轴时的起始点
        var cursorTime = CMTime.zero
        
        for asset in videos {
             //获取视频资源中的视频轨道
            guard let assetTrack = asset.tracks(withMediaType: .video).first else {
                continue
            }
            
            do {
                try track.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: assetTrack, at: cursorTime)
                //光标移动到视频末尾处，以便插入下一段视频
                  cursorTime = CMTimeAdd(cursorTime, asset.duration)
            } catch  {
                print("insert error")
            }
        }
        
    }
    
    func buildAudioTrack()  {
        
        let trackId = kCMPersistentTrackID_Invalid
             guard let trackAudio = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: trackId) else {
                 return
             }
             var cursorTime = CMTime.zero
             for (_,value) in videos.enumerated() {
                 //获取视频资源中的音频轨道
                 guard let assetTrack = value.tracks(withMediaType: .audio).first else {
                     continue
                 }
                 do {
                     try trackAudio.insertTimeRange(CMTimeRange(start: .zero, duration: value.duration), of: assetTrack, at: cursorTime)
                     cursorTime = CMTimeAdd(cursorTime, value.duration)
                 } catch {

                 }
             }
        
    }
    
    func playVideo() {
    
        let playerItem = AVPlayerItem(asset: composition)
//        playerItem.videoComposition = editor.videoComposition
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width , height: UIScreen.main.bounds.size.height - 200)
        playerLayer.position = view.center
        view.layer.addSublayer(playerLayer)
        player.play()
        
    }
    
    func export()  {
    
        let export = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset640x480)
        
        export?.outputURL = MergeViewController.createTemplateFileURL()
        export?.outputFileType = .mp4
        
        export?.exportAsynchronously {  

             let status = export?.status
            if status == AVAssetExportSession.Status.completed {
                
                VideoHelper.saveToAlbum(atURL: export!.outputURL!)
            }

        }
        
    }
    
    // MARK: - utils
      private class func createTemplateFileURL() -> URL {
        
          let path = NSTemporaryDirectory() + "composition.mp4"
        
          print(path)
        
          let fileURL = URL(fileURLWithPath: path)
          if FileManager.default.fileExists(atPath: fileURL.path) {
              do { try FileManager.default.removeItem(at: fileURL) } catch {
                  
              }
          }
          return fileURL
      }
    
    
    private func saveToAlbum(atURL url: URL,complete: @escaping ((Bool) -> Void)){
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }, completionHandler: { (success, error) in
            complete(success)
        })
    }
    
    
    private func showSaveResult(isSuccess: Bool) {
        let message = isSuccess ? "已保存到相册" : "保存失败"
        print("exportMessage = \(message)")
    
    }


}
