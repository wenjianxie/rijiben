import UIKit
import Photos
import AVFoundation

class VideoPlayerViewController: UIViewController {

    // MARK: - Properties
    var asset: PHAsset?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    // MARK: - UI Elements
    private let playerView = UIView()
    private let backButton = UIButton()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPlayer()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .black
        
        // Player View
        playerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerView)
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Back Button
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    // MARK: - Setup Player
    private func setupPlayer() {
        guard let asset = asset else { return }
        
        let options = PHVideoRequestOptions()
        options.version = .current
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [weak self] (avAsset, _, _) in
            guard let avAsset = avAsset as? AVURLAsset else { return }
            
            DispatchQueue.main.async {
                self?.player = AVPlayer(url: avAsset.url)
                self?.playerLayer = AVPlayerLayer(player: self?.player)
                self?.playerLayer?.frame = self?.playerView.bounds ?? .zero
                self?.playerLayer?.videoGravity = .resizeAspect
                self?.playerView.layer.addSublayer(self?.playerLayer ?? CALayer())
                self?.player?.play()
            }
        }
    }
    
    // MARK: - Actions
    @objc private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
}

