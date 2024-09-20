//
//  RZCustomRichTextViewModel.swift
//  RZRichTextView_Example
//
//  Created by rztime on 2023/8/1.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import RZRichTextView
import QuicklySwift
import TZImagePickerController
import Kingfisher
import JXPhotoBrowser
var myLayer:AVPlayerLayer?
/// 使用时，直接将此代码复制到项目中，并完成相关FIXME的地方即可
public extension RZRichTextViewModel {
    
  
    /// 如果有需要自定义实现资源下载，可以放开代码，并实现sync_imageBy、async_imageBy方法
    static var configure: RZRichTextViewConfigure = {
        /// 同步获取图片
        RZRichTextViewConfigure.shared.sync_imageBy = { source in
            print("sync source:\(source ?? "")")
            let imgView = UIImageView()
            imgView.kf.setImage(with: source?.qtoURL)
            return imgView.image
        }
        /// 异步获取图片
        RZRichTextViewConfigure.shared.async_imageBy = { source, complete in
            print("async source:\(source ?? "")")
            let comp = complete
            let s = source
            let imgView = UIImageView()
            imgView.kf.setImage(with: source?.qtoURL) { result in
                let image = try? result.get().image
                comp?(s, image)
            }
        }
        return RZRichTextViewConfigure.shared
    }()
    class func shared(edit: Bool = true) -> RZRichTextViewModel {
        /// 自定义遮罩view 默认RZAttachmentInfoLayerView
//        RZAttachmentOption.register(attachmentLayer: RZAttachmentInfoLayerView.self)
        
        /// 如果有需要自定义实现资源下载，可以放开代码，并实现sync_imageBy、async_imageBy方法
//        _ = RZRichTextViewModel.configure
        
        let viewModel = RZRichTextViewModel.init()
        viewModel.canEdit = edit
        /// 链接颜色
        viewModel.defaultLinkTypingAttributes = [.foregroundColor: UIColor.qhex(0x307bf6), .underlineColor: UIColor.qhex(0x307bf6), .underlineStyle: NSUnderlineStyle.single.rawValue]
        /// 显示音频文件名字
//        viewModel.showAudioName = false
        /// 音频高度
        viewModel.audioAttachmentHeight = 60
        /// 最大输入10w字
        viewModel.maxInputLenght = 100000
        /// 显示已输入字数
        viewModel.showcountType = .showcountandall
        viewModel.countLabelLocation = .bottomRight(x: 1, y: 1)
        /// 空格回车规则
        viewModel.spaceRule = .removeEnd
        /// 当超出长度限制时，会回调此block
        viewModel.morethanInputLength = { [weak viewModel] in
            // FIXME: 这里按需求，可以添加Toast提示
            if viewModel?.canEdit ?? true {
                print("----超出输入字数上限")
            }
        }
        viewModel.shouldInteractWithURL = { url in
            // 如果是自定义跳转，则 return false
            return true
        }
        viewModel.uploadAttachmentsComplete.subscribe({ value in
            print("上传是否完成：\(value)")
        }, disposebag: viewModel)
        /// 有新的附件插入时，需在附件的infoLayer上，添加自定义的视图，用于显示图片、视频、音频，以及交互
        viewModel.reloadAttachmentInfoIfNeed = { [weak viewModel] info in            
            /// 绑定操作，用于重传，删除、预览等功能
            info.operation.subscribe({ [weak viewModel] value in
                switch value {
                case .none: break
                case .delete(let info): // 删除
                    viewModel?.textView?.removeAttachment(info)
                case .preview(let info):// 预览
                    
                    let browser = JXPhotoBrowser()
                
                    browser.numberOfItems = {
                        return 1
                    }
                    if info.type == .image {
                        browser.reloadCellAtIndex = { context in
                            let cell = context.cell as? JXPhotoBrowserImageCell
                            
                            
                            let tempURL = URL.documentsURL.appendingPathComponent(info.src ?? "")
                            cell?.imageView.kf.setImage(with: tempURL)
                        }
                        
                        
                        browser.show()
                    }else if info.type == .video {
                        
                        let videoPlayerVC = VideoPlayerViewController()
                        
                        let tempURL = URL.documentsURL.appendingPathComponent(info.src ?? "")
                        videoPlayerVC.urlVideo = tempURL.absoluteString // 假设 selectedPHAsset 是你选择的视频 PHAsset
                    
                           // 显示预览控制器
                        qAppFrame.present(videoPlayerVC, animated: true, completion: nil)
                        
                    }else if info.type == .audio {
                        
                        let audioPlayerVC = AudioPlayerViewController()
                        let tempURL = URL.documentsURL.appendingPathComponent(info.src ?? "")
                        
                        audioPlayerVC.audioUrl = tempURL.absoluteString
                        qAppFrame.present(audioPlayerVC, animated: true, completion: nil)
                        print("点击了音频\(info.src)")
                    }

                case .upload(let info): // 上传 以及点击重新上传时，将会执行
                    
                    if info.type == .image {
                        
                        if let asset = info.asset {
                            savePHAssetToFileURL(asset: asset) { url in
                                info.src = url
                            }
                        }
                    }else if info.type == .video {

                        if let asset = info.asset {
                            savePHAssetToFileURL(asset: asset) { url in
                                info.src = url
                            }
                            
                            
                            getFirstFrameAndSaveToSandbox(from: asset) { imgurl in
                                info.poster = imgurl
                            }
                        }
                    }
                    info.uploadStatus.accept(.complete(success: true, info: "上传完成"))
  
                }
            }, disposebag: info.dispose)
        }
        /// 自定义功能，自行实现的话需要返回true，返回false时由内部方法实现
        viewModel.didClickedAccessoryItem = { [weak viewModel] item in
            switch item.type {
            case .media:  /// 自定义添加附件，选择了附件之后，插入到textView即可
                if !(viewModel?.textView?.canInsertContent() ?? false) {
                    viewModel?.morethanInputLength?()
                    return true
                }
                // FIXME: 此处自行实现选择音视频、图片的功能，将数据写入到RZAttachmentInfo，并调用viewModel.textView?.insetAttachment(info)即可
                QActionSheetController.show(options: .init(options: [.title("选择附件"), .action("图片"), .action("视频"), .action("音频"), .cancel("取消")])) { [weak viewModel] index in
                    if index < 0 { return }
                    if index == 2, let viewModel = viewModel {
 
                        let recordView = RecordView()
                        recordView.frame = CGRect.init(x: 0, y: kScreenH - 300, width: kScreenW, height: 300)
                        
    
                        recordView.backgroundColor = UIColor.init(hex: 0xeef2f5)
                        ez.topMostVC?.view.addSubview(recordView)
                        UIApplication.shared.windows[0].endEditing(true)
//                        ez.topMostVC?.dismiss(animated: true)
                        recordView.stopRecordingBlock = { url in
                            print("url == \(url)")
                            print("url == \(url)")
                            let info = RZAttachmentInfo.init(type: .audio, image: nil, asset: nil, filePath: url, maxWidth: viewModel.attachmentMaxWidth, audioHeight: viewModel.audioAttachmentHeight)
                            
                            info.src = url
                    //                        /// 插入音频
                                viewModel.textView?.insetAttachment(info)
                        }
                        return
                    }
                    let vc = TZImagePickerController.init(maxImagesCount: 1, delegate: nil)
                    vc?.allowPickingImage = index == 0
                    vc?.allowPickingVideo = index == 1
                    vc?.allowTakeVideo = false
                    vc?.allowTakePicture = false
                    vc?.allowCrop = false
                    vc?.didFinishPickingPhotosHandle = { [weak viewModel] (photos, assets, _) in
                        if let image = photos?.first, let asset = assets?.first as? PHAsset, let viewModel = viewModel {
                            let info = RZAttachmentInfo.init(type: .image, image: image, asset: asset, filePath: nil, maxWidth: viewModel.attachmentMaxWidth, audioHeight: viewModel.audioAttachmentHeight)
                            /// 插入图片
                            viewModel.textView?.insetAttachment(info)
                        }
                    }
                    vc?.didFinishPickingVideoHandle = { [weak viewModel] (image, asset) in
                        if let image = image, let asset = asset, let viewModel = viewModel {
                            let info = RZAttachmentInfo.init(type: .video, image: image, asset: asset, filePath: nil, maxWidth: viewModel.attachmentMaxWidth, audioHeight: viewModel.audioAttachmentHeight)
                            /// 插入视频
                            viewModel.textView?.insetAttachment(info)
                        }
                    }
                    if let vc = vc {
                        qAppFrame.present(vc, animated: true, completion: nil)
                    }
                }
                
                return true
            case.image:
                break
            case .video:
                break
            case .audio:
                break
            case .custom1:
                if let item = viewModel?.inputItems.first(where: {$0.type == .custom1}) {
                    item.selected = !item.selected
                    /// 刷新工具条item
                    viewModel?.reloadDataWithAccessoryView?()
                    print("自定义功能1")
                }
                return true
            default:
                break
            }
            return false
        }
        
        
       
        return viewModel
    }
    
   class func playSavedAudio(url:String) {
        let audioFilePath = url
        if let fileURL = URL(string: audioFilePath) {
            AudioPlayerManager.shared.playAudioFile(at: fileURL)
        } else {
            print("Invalid file URL")
        }
    }


    // 将 PHAsset 转换为本地文件 URL，并返回 URL 的字符串表示
  class  func savePHAssetToFileURL(asset: PHAsset, completion: @escaping (String?) -> Void) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        let manager = PHImageManager.default()
        
        if asset.mediaType == .video {
            let videoOptions = PHVideoRequestOptions()
            videoOptions.isNetworkAccessAllowed = true
            videoOptions.version = .current
            
            manager.requestAVAsset(forVideo: asset, options: videoOptions) { avAsset, _, _ in
                guard let urlAsset = avAsset as? AVURLAsset else {
                    completion(nil)
                    return
                }
                
                // Copy video file to documents directory
                let fileURL = urlAsset.url
              
                let tempURL = URL.documentsURL.appendingPathComponent(fileURL.lastPathComponent)
                
                do {
                    if FileManager.default.fileExists(atPath: tempURL.path) {
                        try FileManager.default.removeItem(at: tempURL)
                    }
                    try FileManager.default.copyItem(at: fileURL, to: tempURL)
                    completion(fileURL.lastPathComponent)
                } catch {
                    print("Error copying video file: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        } else if asset.mediaType == .image {
            manager.requestImageData(for: asset, options: options) { data, _, _, _ in
                guard let data = data else {
                    completion(nil)
                    return
                }
                
                // Create a file URL for the image in documents directory
                let fileName = UUID().uuidString + ".jpg" // Adjust extension based on image format
//                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let tempURL = URL.documentsURL.appendingPathComponent(fileName)
                
                do {
                    try data.write(to: tempURL)
                    completion(fileName)
                } catch {
                    
                    print("Error saving image file: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }


    // 将 UIImage 保存到沙盒目录，并返回图片文件路径
 class  func saveImageToSandbox(image: UIImage) -> String? {
        // 获取沙盒中的 Documents 目录
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        // 为图片生成一个唯一的文件名
        let fileName = "firstFrame_\(UUID().uuidString).jpg"
        
        // 创建图片的完整路径
     let fileURL = URL.documentsURL.appendingPathComponent(fileName)
            
            // 将 UIImage 转换为 JPEG 格式的 Data
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                do {
                    // 将图片数据写入沙盒路径
                    try imageData.write(to: fileURL)
                    print("Image saved to: \(fileURL.path)")
                    return fileName // 返回图片的沙盒路径
                } catch {
                    print("Error saving image to sandbox: \(error.localizedDescription)")
                }
            }
        
        
        return nil
    }
    
  class  func getFirstFrameAndSaveToSandbox(from asset: PHAsset, completion: @escaping (String?) -> Void) {
        // 确保 PHAsset 是视频类型
        guard asset.mediaType == .video else {
            completion(nil)
            return
        }

        // 获取 PHAsset 的 AVAsset
        let options = PHVideoRequestOptions()
        options.version = .current

        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, audioMix, info) in
            guard let avAsset = avAsset else {
                completion(nil)
                return
            }

            // 使用 AVAssetImageGenerator 生成视频的首帧
            let imageGenerator = AVAssetImageGenerator(asset: avAsset)
            imageGenerator.appliesPreferredTrackTransform = true  // 保证图片方向正确
            
            let time = CMTime(seconds: 0, preferredTimescale: 60) // 获取视频开始的帧
            var actualTime = CMTime.zero

            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
                let image = UIImage(cgImage: cgImage)
                
                // 保存图片到沙盒目录
                if let imagePath = self.saveImageToSandbox(image: image) {
                    completion(imagePath) // 返回图片的沙盒地址
                } else {
                    completion(nil) // 保存失败
                }
                
            } catch {
                print("Error generating image: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }




    
   @objc func playerDidFinishPlaying(notification: Notification) {
       
       print("这里之心攻略")
           // 移除 AVPlayerLayer
//                           myLayer?.removeFromSuperlayer()
//                           myLayer = nil
//           
//           // 移除通知监听
//           NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
       }
}
/// 模拟上传
class UploadTaskTest {
    ///  模拟上传，testVM主要用于释放timer
    class func uploadFile(id: Any, testVM: NSObject, progress:((_ progress: CGFloat) -> Void)?) {
        var p: CGFloat = 0
        Timer.qtimer(interval: 0.5, target: testVM, repeats: true, mode:.common) { timer in
            p += 0.1
            progress?(p)
            if p >= 1 {
                timer.invalidate()
            }
        }
    }
}
