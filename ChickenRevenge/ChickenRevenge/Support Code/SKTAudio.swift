//
//  SKTAudio.swift
//  ChickenRevenge
//
//  Created by Luigi Penza on 12/12/23.
//

import AVFoundation

public class SKTAudio {
    public var musicOn = true
    public var soundsOn = true
    public var backgroundMusicPlayer: AVAudioPlayer?
    public var soundEffectPlayer: AVAudioPlayer?
    
    
    public class func sharedInstance() -> SKTAudio {
        return SKTAudioInstance
    }
    
    public func playBackgroundMusic() {
        // Ensure the backgroundMusicPlayer is not nil and play it
        backgroundMusicPlayer?.play()
    }
    
    public func playBackgroundMusic(_ filename: String) {
        if self.musicOn == true {
            self.backgroundMusicPlayer?.volume = 1.0
        } else {
            self.backgroundMusicPlayer?.volume = 0.0
        }
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url!)
        } catch let error1 as NSError {
            error = error1
            backgroundMusicPlayer = nil
        }
        if let player = backgroundMusicPlayer {
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
        } else {
            print("Could not create audio player: \(error!)")
        }
    }
    
    public func pauseBackgroundMusic() {
        if let player = backgroundMusicPlayer {
            if player.isPlaying {
                player.pause()
            }
        }
    }
    
    public func resumeBackgroundMusic() {
        if let player = backgroundMusicPlayer {
            if !player.isPlaying {
                player.play()
            }
        }
    }
    
    public func playSoundEffect(_ filename: String) {
        if self.soundsOn == true {
            self.soundEffectPlayer?.volume = 1.0
        } else {
            self.soundEffectPlayer?.volume = 0.0
        }
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url!)
        } catch let error1 as NSError {
            error = error1
            soundEffectPlayer = nil
        }
        if let player = soundEffectPlayer {
            player.numberOfLoops = 0
            player.prepareToPlay()
            player.play()
        } else {
            print("Could not create audio player: \(error!)")
        }
    }
    
    public func preloadBackgroundMusic(_ fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("Background music file not found: \(fileName)")
            return
        }

        do {
            // Initialize the audio player without playing
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.prepareToPlay()
        } catch {
            print("Error loading background music: \(error.localizedDescription)")
        }
    }
    
    init() {
        self.musicOn = true
        self.soundsOn = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private let SKTAudioInstance = SKTAudio()
