
import UIKit
import AVFoundation

public class PreviewView: UIImageView {
    
    private var playerLayer: AVPlayerLayer?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .black
        contentMode = .scaleAspectFit
    }
    
    func startVideoPlaying(moviePath: String) {
        
        let player = AVPlayer(url: URL(fileURLWithPath: moviePath))
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = bounds
        
        layer.addSublayer(playerLayer)
        
        player.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playVideoCompletion), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        self.playerLayer = playerLayer
        
    }
    
    func stopVideoPlaying() {
        
        guard let player = playerLayer?.player else {
            return
        }
        
        player.pause()
        playerLayer?.removeFromSuperlayer()
        
        playerLayer = nil
        
    }
    
    public override func layoutSubviews() {
        playerLayer?.frame = bounds
    }
    
    @objc func playVideoCompletion(_ notification: Notification) {
        guard let player = playerLayer?.player else {
            return
        }
        player.seek(to: kCMTimeZero)
        player.play()
    }
    
}

