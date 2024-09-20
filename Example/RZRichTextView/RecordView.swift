//
//  RecordView.swift
//  RZRichTextView_Example
//
//  Created by macer on 2024/9/18.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation
class RecordView: UIView {

    let recordBotton = UIButton()
    
    let pointView = UIView()
    
    var audioFileName:String = ""
    var audioRecorder: AVAudioRecorder?
    var timer: Timer?
    var powerLevels: [CGFloat] = [] // 保存实时音量功率，用来绘制波形
    let waveformView = WaveformView() // 自定义的波形视图
    
    let timeLab = UILabel()
    
    var stopRecordingBlock:(((String))->())?
    private var elapsedTime: TimeInterval = 0  // 记录经过的时间（秒）
    func setupUI() {
        
        timeLab.adhere(toSuperView: self).layout { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(0)
        }.config { lb in
            lb.font = 16.font
            lb.textColor = .k66Color
            lb.text = "00:00:00"
        }
        
        recordBotton.adhere(toSuperView: self).layout { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
            make.bottom.equalToSuperview().offset(-60)
            
        }.config { btn in
            btn.layer.borderWidth = 2
            btn.layer.borderColor = UIColor.gray.cgColor
            btn.layer.cornerRadius = 50
            btn.clipsToBounds = true
            
            btn.addTarget(self, action: #selector(clickRecordBotton(sender:)), for: .touchUpInside)
        }
        
        pointView.adhere(toSuperView: recordBotton).layout { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(90)
        }.config { lv in
            lv.backgroundColor = .red
            lv.layer.cornerRadius = 45
            lv.clipsToBounds = true
            lv.isUserInteractionEnabled = false
        }
        
        recordBotton.backgroundColor = UIColor.init(hex: 0xeef2f5)
        
        setupAudioRecorder()
        setupWaveformView()
    }
    
    // 定时器每秒执行一次，更新时间
        @objc private func updateTimer() {
            elapsedTime += 1  // 增加一秒
            timeLab.text = formatTime(elapsedTime / 10)
        }
        
        // 将时间格式化为 "hh:mm:ss"
        private func formatTime(_ timeInterval: TimeInterval) -> String {
            
            let hours = Int(timeInterval) / 3600
            let minutes = (Int(timeInterval) % 3600) / 60
            let seconds = Int(timeInterval) % 60
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        
    
    func setupAudioRecorder() {
           let audioSession = AVAudioSession.sharedInstance()
           do {
               try audioSession.setCategory(.playAndRecord, mode: .default)
               try audioSession.setActive(true)
               
               let settings = [
                   AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                   AVSampleRateKey: 44100.0,
                   AVNumberOfChannelsKey: 1,
                   AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
               ] as [String : Any]
               
               audioRecorder = try AVAudioRecorder(url: getAudioFileURL(), settings: settings)
               audioRecorder?.isMeteringEnabled = true
               audioRecorder?.prepareToRecord()
           } catch {
               print("Error setting up audio recorder: \(error)")
           }
       }
       
    func startRecording() {
        audioRecorder?.record()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateAudioMeter), userInfo: nil, repeats: true)
    }

    @objc func updateAudioMeter() {
        audioRecorder?.updateMeters()
        updateTimer()
        if let averagePower = audioRecorder?.averagePower(forChannel: 0) {
            // 将 dB 值转换为更合适的线性值
            let linearPower = pow(10, averagePower / 20) // dB 转为线性值
            
            // 线性值通常范围在 0.001 到 1 之间，我们需要调整范围
            let normalizedPower = CGFloat(max(0, min(1, linearPower)))
            
            // 添加到波形数组
            powerLevels.append(normalizedPower)
            
            // 限制数组长度，避免无限增长
            if powerLevels.count > 100 {
                powerLevels.removeFirst()
            }
            
            // 更新波形
            waveformView.update(with: powerLevels)
        }
    }



       func stopRecording() {
           audioRecorder?.stop()
           timer?.invalidate()
           
           // 获取录音保存的文件路径
               if let recordedFileURL = audioRecorder?.url {
                   print("音频文件已保存到：\(recordedFileURL)")
                   
                   stopRecordingBlock?(audioFileName)
               }
           removeFromSuperview()
       }

       func getAudioFileURL() -> URL {
           
           let uuid = UUID().uuidString
           audioFileName = "audio\(uuid).m4a"
           let url = URL.documentsURL.appendingPathComponent(audioFileName)
         
           return url
       }

       func setupWaveformView() {
           
           waveformView.backgroundColor = UIColor.init(hex: 0xeef2f5)
           waveformView.frame = CGRect.init(x: 0, y: 20, width: kScreenW, height: 80)
           
           addSubview(waveformView)
           
       }
    
    @objc func clickRecordBotton(sender:UIButton) {
        print("点击了录音按钮")
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected == true {
            pointView.update { make in
                make.width.height.equalTo(40)
            }.config { lv in
                lv.layer.cornerRadius = 6
                lv.clipsToBounds = true
            }
            startRecording()
        }else {
            pointView.update { make in
                make.width.height.equalTo(90)
            }.config { lv in
                lv.layer.cornerRadius = 45
                lv.clipsToBounds = true
            }
            
            stopRecording()
        }
      
        
       
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class WaveformView: UIView {
    var powerLevels: [CGFloat] = []

    func update(with powerLevels: [CGFloat]) {
        self.powerLevels = powerLevels
        setNeedsDisplay() // 通知系统重新绘制视图
    }

    override func draw(_ rect: CGRect) {
        guard powerLevels.count > 0 else { return }
        
        let path = UIBezierPath()
        let midY = bounds.height / 2
        let step = bounds.width / CGFloat(powerLevels.count) // 根据声波数据个数计算每个波的间隔
        
        for (index, powerLevel) in powerLevels.enumerated() {
            let x = CGFloat(index) * step
            let y = midY - (powerLevel * midY)
            let endY = midY + (powerLevel * midY)
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x, y: endY))
        }
        
        UIColor.blue.setStroke() // 设置波形线的颜色
        path.lineWidth = 2.0
        path.stroke() // 绘制波形
    }
}
