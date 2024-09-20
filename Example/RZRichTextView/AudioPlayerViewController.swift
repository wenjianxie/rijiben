//
//  AudioPlayerViewController.swift
//  RZRichTextView_Example
//
//  Created by macer on 2024/9/20.
//  Copyright © 2024 CocoaPods. All rights reserved.
//


import UIKit
import AVFoundation

class AudioPlayerViewController: UIViewController {
    
    
    var audioUrl:String = ""
    // UI 控件
    private var playButton: UIButton!
    private var pauseButton: UIButton!
    private var stopButton: UIButton!
    private var progressSlider: UISlider!
    private var currentTimeLabel: UILabel!
    private var durationLabel: UILabel!
    
    // 定时器用于更新进度条
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 页面消失时停止更新进度条
        timer?.invalidate()
    }
    
    // 设置 UI 控件
    private func setupUI() {
        // 播放按钮
        playButton = UIButton(type: .system)
        playButton.setTitle("Play", for: .normal)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playButton)
        
        // 暂停按钮
        pauseButton = UIButton(type: .system)
        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pauseButton)
        
        // 停止按钮
        stopButton = UIButton(type: .system)
        stopButton.setTitle("Stop", for: .normal)
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stopButton)
        
        // 当前时间标签
        currentTimeLabel = UILabel()
        currentTimeLabel.text = "00:00"
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currentTimeLabel)
        
        // 总时长标签
        durationLabel = UILabel()
        durationLabel.text = "00:00"
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(durationLabel)
        
        // 进度条
        progressSlider = UISlider()
        progressSlider.addTarget(self, action: #selector(progressSliderChanged), for: .valueChanged)
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressSlider)
        
        // 布局约束
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            
            pauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pauseButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
            
            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.topAnchor.constraint(equalTo: pauseButton.bottomAnchor, constant: 20),
            
            currentTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            currentTimeLabel.topAnchor.constraint(equalTo: stopButton.bottomAnchor, constant: 40),
            
            durationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            durationLabel.topAnchor.constraint(equalTo: stopButton.bottomAnchor, constant: 40),
            
            progressSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 10),
            progressSlider.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -10),
            progressSlider.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor)
        ])
    }
    
    // 播放按钮点击事件
    @objc private func playButtonTapped() {
        let audioFilePath = audioUrl
        
        if let fileURL = URL(string: audioFilePath) {
            AudioPlayerManager.shared.playAudioFile(at: fileURL)
            startTimer()
        }
    }
    
    // 暂停按钮点击事件
    @objc private func pauseButtonTapped() {
        AudioPlayerManager.shared.pause()
        stopTimer()
    }
    
    // 停止按钮点击事件
    @objc private func stopButtonTapped() {
        AudioPlayerManager.shared.stop()
        stopTimer()
        resetUI()
    }
    
    // 进度条改变事件
    @objc private func progressSliderChanged() {
        let totalDuration = AudioPlayerManager.shared.getAudioDuration() ?? 0
        let newTime = TimeInterval(progressSlider.value) * totalDuration
        AudioPlayerManager.shared.setCurrentTime(newTime)
    }
    
    // 开始更新进度条
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
    }
    
    // 停止更新进度条
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // 更新 UI（进度条和时间标签）
    @objc private func updateUI() {
        if let currentTime = AudioPlayerManager.shared.getCurrentTime(),
           let totalDuration = AudioPlayerManager.shared.getAudioDuration() {
            progressSlider.value = Float(currentTime / totalDuration)
            currentTimeLabel.text = formatTime(currentTime)
            durationLabel.text = formatTime(totalDuration)
        }
    }
    
    // 重置 UI 控件
    private func resetUI() {
        progressSlider.value = 0
        currentTimeLabel.text = "00:00"
        durationLabel.text = "00:00"
    }
    
    // 格式化时间为 "mm:ss"
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
