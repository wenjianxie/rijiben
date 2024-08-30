//
//  RZAttachmentInfoLayerView.swift
//  RZRichTextView
//
//  Created by rztime on 2023/8/8.
//

import UIKit
import QuicklySwift
import Kingfisher
import Photos
/// 操作
public enum RZAttachmentOperation {
    case none
    case upload(info: RZAttachmentInfo)
    case delete(info: RZAttachmentInfo)
    case preview(info: RZAttachmentInfo)
}
/// 可以自定义附件显示的页面，参考 RZAttachmentInfoLayerView
public protocol RZAttachmentInfoLayerProtocol: NSObjectProtocol {
    /// 操作
    var operation: QPublish<RZAttachmentOperation> {get set}
    ///  附件信息
    var info: RZAttachmentInfo? {get set}
    /// 是否可以编辑
    var canEdit: Bool {get set}
    /// 图片
    var imageView: UIImageView {get set}
    /// 用于判断释放
    var dispose: NSObject {get set}
    /// 显示音频文件名 默认true
    var showAudioName: Bool {get set}
    /// 图片或者音频view上下左右边距
    var imageViewEdgeInsets: UIEdgeInsets { get }
}
open class RZAttachmentInfoLayerView: UIView, RZAttachmentInfoLayerProtocol {
    public var operation: QuicklySwift.QPublish<RZAttachmentOperation> = .init(value: .none)
    
    public var info: RZAttachmentInfo? {
        didSet {
            dispose = .init()
            operation.accept(.none)
            guard let info = info else { return }
            imageContent.isHidden = info.type == .audio
            audioContent.isHidden = info.type != .audio
            self.playBtn.isHidden = info.type != .video
            switch info.type {
            case .image:
                if let asset = info.asset {
                    let option = PHImageRequestOptions.init()
                    option.isNetworkAccessAllowed = true
                    option.resizeMode = .fast
                    option.deliveryMode = .highQualityFormat
                    PHImageManager.default().requestImageData(for: asset, options: option) { [weak self] data, _, _, _ in
                        if let imageData = data {
                            self?.imageView.kf.setImage(with: .provider(RawImageDataProvider(data: imageData, cacheKey: asset.localIdentifier))) { [weak self] _ in
                                self?.updateImageViewSize()
                            }
                        }
                    }
                } else if let url = info.src {
                    if let c = RZRichTextViewConfigure.shared.async_imageBy {
                        let complete: ((String?, UIImage?) -> Void)? = { [weak self] source, image in
                            self?.imageView.image = image
                            self?.updateImageViewSize()
                        }
                        c(url, complete)
                    } else {
                        self.imageView.kf.setImage(with: url.qtoURL, completionHandler: { [weak self] _ in
                            self?.updateImageViewSize()
                        })
                    } 
                } else {
                    info.imagePublish.subscribe({ [weak self] value in
                        guard let self = self else { return }
                        self.imageView.image = value
                        self.updateImageViewSize()
                    }, disposebag: dispose)
                }
            case .video:
                info.imagePublish.subscribe({ [weak self] value in
                    guard let self = self else { return }
                    self.imageView.image = value
                    self.updateImageViewSize()
                }, disposebag: dispose)
            case .audio:
                if let path = info.path ?? info.src  {
                    self.nameLabel.text = path.qtoURL?.lastPathComponent
                }
            }
            self.layoutIfNeeded()

            info.uploadStatus.subscribe({ [weak self] value in
                switch value {
                case .idle:
                    self?.infoLabel.text = "等待上传..."
                    self?.infoLabel.isHidden = false
                    self?.updateProgress(0)
                case .uploading(let progress):
                    self?.infoLabel.text = "上传中(\(Int(progress * 100))%)"
                    self?.infoLabel.isHidden = false
                    self?.updateProgress(progress)
                case .complete(let success, let info):
                    self?.infoLabel.isHidden = success
                    self?.infoLabel.text = info
                    self?.progressView.isHidden = success
                    self?.updateProgress(1)
                }
            }, disposebag: dispose)

            self.reupload()
        }
    }
    
    /// 是否可以编辑
    public var canEdit: Bool = true {
        didSet {
            contentView.isHidden = !canEdit
        }
    }
    public var showAudioName: Bool = true {
        didSet {
            self.nameLabel.isHidden = !showAudioName
        }
    }
    /// 图片视频相关view
    // 显示的图片
    public var imageView: UIImageView = AnimatedImageView.init().qcontentMode(.scaleAspectFit).qcornerRadius(3, true)
    /// 播放按钮
    var playBtn: UIButton = .init(type: .custom).qimage(RZRichImage.imageWith("play")).qisUserInteractionEnabled(false)
    
    /// 音频相关view
    var nameLabel = UILabel().qfont(.systemFont(ofSize: 12))
    var audioPlayBtn = UIButton.init(type: .custom).qimage(RZRichImage.imageWith("audio")).qisUserInteractionEnabled(false)
    
    /// 删除按钮
    var deleteBtn: UIButton = .init(type: .custom).qimage(RZRichImage.imageWith("delete"))
    /// 上传进度
    var progressView: UIView = .init()
        .qcornerRadius(2, true)
        .qbody([
            UIView().qbackgroundColor(.qhex(0xff3333)).qmakeConstraints({ make in
                make.edges.equalToSuperview()
            })
        ])
    /// 上传提示信息
    var infoLabel: UILabel = .init().qbackgroundColor(.qhex(0x000000, a: 0.3)).qfont(.systemFont(ofSize: 12)).qtextColor(.white)
    let imageContent: UIView = .init()
    let audioContent: UIView = .init().qbackgroundColor(.qhex(0xdddddd)).qcornerRadius(4, true)
    
    let contentView: UIView = .init()
    
    public var dispose: NSObject = .init()
    /// 图片或者音频view上下左右边距
    public var imageViewEdgeInsets: UIEdgeInsets {
        return .init(top: 15, left: 3, bottom: 0, right: 15)
    }
    /// 0.0-1.0
    public func updateProgress(_ progress: CGFloat) {
        var bounds = self.progressView.bounds
        bounds.origin.x = bounds.size.width - bounds.size.width * progress
        self.progressView.bounds = bounds
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        audioPlayBtn.imageView?.contentMode = .scaleAspectFit
        let stackView = [imageContent, audioContent].qjoined(aixs: .vertical, spacing: 0, align: .fill, distribution: .equalSpacing)
        self.qbody([
            stackView.qmakeConstraints({ make in
                make.left.equalToSuperview().inset(3)
                make.top.right.equalToSuperview().inset(15)
                make.bottom.lessThanOrEqualToSuperview()
            }),
            contentView.qmakeConstraints({ make in
                make.edges.equalToSuperview()
            })
        ])
        contentView.qbody([
            infoLabel.qmakeConstraints({ make in
                make.left.bottom.right.equalTo(stackView)
                make.height.equalTo(18)
            }),
            progressView.qmakeConstraints({ make in
                make.left.bottom.right.equalTo(self.infoLabel)
                make.height.equalTo(2)
            }),
            deleteBtn.qmakeConstraints({ make in
                make.top.right.equalToSuperview()
                make.size.equalTo(30)
            })
        ])
        imageContent.qbody([
            imageView.qmakeConstraints({ make in
                make.top.left.right.equalToSuperview()
                make.bottom.lessThanOrEqualToSuperview()
            }),
            playBtn.qmakeConstraints({ make in
                make.center.equalToSuperview()
                make.size.equalTo(40)
            })
        ])
        let line = UIView().qbackgroundColor(.qhex(0xbbbbbb, a: 1))
        audioContent.qbody([
            audioPlayBtn.qmakeConstraints({ make in
                make.size.equalTo(30)
                make.left.top.bottom.equalToSuperview().inset(15)
            }),
            nameLabel.qmakeConstraints({ make in
                make.left.equalTo(self.audioPlayBtn.snp.right).offset(15)
                make.right.equalToSuperview().inset(20)
                make.centerY.equalToSuperview()
            }),
            line.qmakeConstraints({ make in
                make.left.right.centerY.equalTo(self.nameLabel)
                make.height.equalTo(1)
            }),
        ])
        nameLabel.qisHiddenChanged { [weak line] view in
            line?.isHidden = !view.isHidden
        }
        
        self.qtap { [weak self] view in
            if let info = self?.info {
                self?.operation.accept(.preview(info: info))
            }
        }
        self.deleteBtn.qtap { [weak self] view in
            if let info = self?.info {
                self?.operation.accept(.delete(info: info))
            }
        }
        self.infoLabel.qtap { [weak self] view in
            self?.reupload()
        }
    }
    /// 重新上传
    func reupload() {
        guard let info = self.info else { return }
        switch info.uploadStatus.value {
        case .idle:
            self.operation.accept(.upload(info: info))
        case .uploading(_):
            self.operation.accept(.none)
        case .complete(let success, _):
            if !success {
                self.operation.accept(.upload(info: info))
            }
        }
    }
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateImageViewSize() {
        guard let image = self.imageView.image else { return }
        let size = image.size
        self.imageView.snp.makeConstraints { make in
            make.height.equalTo(self.imageView.snp.width).multipliedBy(size.height / size.width)
        }
    }
}
