//
//  AudioManager.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 27/11/2025.
//
import AVFoundation
import UIKit
import Foundation

final class AudioManager {
    static let shared = AudioManager()

    // MARK: - Properties
    var soundEffectsEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: "soundEffectsEnabled") == nil {
                return true  // Default: enabled
            }
            return UserDefaults.standard.bool(forKey: "soundEffectsEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "soundEffectsEnabled")
        }
    }

    var hapticsEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: "hapticsEnabled") == nil {
                return true  // Default: enabled
            }
            return UserDefaults.standard.bool(forKey: "hapticsEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hapticsEnabled")
        }
    }

    var soundVolume: Double {
        get {
            if UserDefaults.standard.object(forKey: "soundVolume") == nil {
                return 0.7  // Default: 70% volume
            }
            return UserDefaults.standard.double(forKey: "soundVolume")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "soundVolume")
        }
    }

    // Storage for audio players (one per sound effect)
    private var audioPlayers: [SoundEffect: AVAudioPlayer] = [:]

    // Haptic feedback generators
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {
        preloadSounds()
        prepareHaptics()
    }

    // MARK: - Sound Management
    private func preloadSounds() {
        for sound in [SoundEffect.cardSelect, .chipPlace, .sequenceComplete, .turnChange, .gameWin] {
            guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
                continue
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                player.volume = Float(soundVolume)
                audioPlayers[sound] = player
            } catch {
                print("Failed to load sound: \(sound.filename)")
            }
        }
    }

    func playSound(_ sound: SoundEffect) {
        guard soundEffectsEnabled else { return }
        
        guard let player = audioPlayers[sound] else {
            return
        }
        
        player.volume = Float(soundVolume)
        
        if player.isPlaying {
            player.stop()
            player.currentTime = 0
        }
        
        player.play()
    }

    func updateVolume(_ volume: Double) {
        soundVolume = volume
        for player in audioPlayers.values {
            player.volume = Float(volume)
        }
    }

    // MARK: - Haptic Feedback
    private func prepareHaptics() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }

    func playHaptic(_ type: HapticType) {
        guard hapticsEnabled else { return }
    
        switch type {
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        case .selection:
            selectionGenerator.selectionChanged()
        case .success:
            notificationGenerator.notificationOccurred(.success)
        case .warning:
            notificationGenerator.notificationOccurred(.warning)
        case .error:
            notificationGenerator.notificationOccurred(.error)
        }
    }
    // MARK: - Combined Audio + Haptics
    func play(sound: SoundEffect, haptic: HapticType) {
        playSound(sound)
        playHaptic(haptic)
    }
    
}
