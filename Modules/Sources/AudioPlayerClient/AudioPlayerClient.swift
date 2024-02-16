//
//  AudioPlayerClient.swift
//
//
//  Created by Yulian on 23.01.2024.

import ComposableArchitecture
import Dependencies

import AVFoundation

public struct AudioPlayerClient {
    public var load: @Sendable (_ url: URL) -> Void
    public var play: @Sendable (_ url: URL, _ rate: Float) -> AsyncStream<CMTime>
    public var pause: @Sendable () -> Void
    public var seek5SecBackwards: @Sendable () -> Void
    public var seek10SecForward: @Sendable () -> Void
    public var seekTo: @Sendable (_ time: CMTime) -> Void
    public var setRate: @Sendable (_ rate: Float) -> Void
    public var duration: @Sendable (_ url: URL) async -> CMTime?
}

public extension DependencyValues {
    var audioPlayerClient: AudioPlayerClient {
        get { self[AudioPlayerClient.self] }
        set { self[AudioPlayerClient.self] = newValue }
    }
}

extension AudioPlayerClient: DependencyKey {
    public static var liveValue: Self {
        let player = LockIsolated(AVPlayer())

        return Self(
            load: { url in
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [])
                player.withValue {
                    $0.replaceCurrentItem(with: AVPlayerItem(url: url))
                    $0.actionAtItemEnd = .pause
                }
            },
            play: { url, rate in
                AsyncStream { continuation in
                    if (player.value.currentItem?.asset as? AVURLAsset)?.url != url {
                        player.value.replaceCurrentItem(with: AVPlayerItem(url: url))
                    }
                    
                    player.value.actionAtItemEnd = .pause
                    player.value.play()
                    player.value.rate = rate
                    
                    let interval = CMTimeMake(value: 1, timescale: 4)
                    player.value.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { time in
                        continuation.yield(time)
                    }
                }
            },
            pause: {
                player.withValue {
                    $0.pause()
                }
            }, seek5SecBackwards: {
                player.withValue {
                    let currentTimeSec = $0.currentTime().seconds
                    let newTimeSec = currentTimeSec - 5 > 0 ? currentTimeSec - 5 : 0
                    let newTime = CMTime(value: Int64(newTimeSec * 1000 as Float64), timescale: 1000)
                    $0.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
                }
            }, seek10SecForward: {
                player.withValue {
                    let currentTimeSec = $0.currentTime().seconds
                    let newTimeSec = currentTimeSec + 10
                    let newTime = CMTime(value: Int64(newTimeSec * 1000 as Float64), timescale: 1000)
                    $0.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
                }
            }, seekTo: { time in
                player.withValue {
                    $0.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
                }
            }, setRate: { rate in
                player.withValue {
                    $0.rate = rate
                }
            }, duration: { url in
                let asset = AVURLAsset(url: url, options: nil)
                return try? await asset.load(.duration) 
            }
        )
    }
}
