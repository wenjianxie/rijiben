//
//  AudioPlayerManager.swift
//  RZRichTextView_Example
//
//  Created by macer on 2024/9/20.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayerManager: NSObject {
    // 单例模式（如果你希望在整个应用中共享一个音频播放器）
    static let shared = AudioPlayerManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    // 初始化方法私有化，确保只能通过 shared 获取实例
    private override init() {}
    
    // 播放音频文件
    func playAudioFile(at fileURL: URL) {
        do {
            // 初始化音频播放器
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("开始播放音频：\(fileURL)")
        } catch {
            print("无法播放音频文件：\(error.localizedDescription)")
        }
    }
    
    // 暂停音频播放
    func pause() {
        if let player = audioPlayer, player.isPlaying {
            player.pause()
            print("音频播放暂停")
        }
    }
    
    // 恢复播放
    func resume() {
        if let player = audioPlayer, !player.isPlaying {
            player.play()
            print("恢复播放音频")
        }
    }
    
    // 停止播放
    func stop() {
        if let player = audioPlayer {
            player.stop()
            audioPlayer = nil
            print("停止播放音频")
        }
    }
    
    // 获取当前是否在播放
    func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    // 获取音频文件的时长
    func getAudioDuration() -> TimeInterval? {
        return audioPlayer?.duration
    }
    
    // 获取当前播放的进度
    func getCurrentTime() -> TimeInterval? {
        return audioPlayer?.currentTime
    }
    
    // 设置播放进度
    func setCurrentTime(_ time: TimeInterval) {
        audioPlayer?.currentTime = time
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioPlayerManager: AVAudioPlayerDelegate {
    // 音频播放完成的回调
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("音频播放完成")
        } else {
            print("音频播放未成功完成")
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("音频解码错误：\(error.localizedDescription)")
        }
    }
}
