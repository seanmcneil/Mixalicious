import AVFoundation
import Combine
import SwiftUI

/// API for clients to interact with this library for modifying their asset objects
public final class Mixalicious: ObservableObject, MixaliciousAPI {
    /// The percentage of the operation completed, on a 0.0...1.0 scale
    ///
    /// - Note: When a function is called, regardless of how it completes, this will be set to 1.0 on completion
    @Published public private(set) var completionPercent = 0.0

    private let insertAudio = InsertAudio()
    private let extractAudio = ExtractAudio()
    private let trimAsset = TrimAsset()
    private let scaleAsset = ScaleAsset()
    private let combineAssets = CombineAssets()

    // MARK: Progress tracking

    /// Value representing how many units to count. A higher value allows for more precise results
    private let totalUnitCount: Int64 = 1000

    /// Progress for updates on writing output
    private var progress: Progress

    private let timerPublisher = Timer.publish(every: 0.1,
                                               on: .main,
                                               in: .default)
    /// For cancelling the timer
    private var cancellableTimerPublisher: Cancellable?

    /// Initializes the library for use by clients
    public init() {
        progress = Progress(totalUnitCount: totalUnitCount)

        cancellableTimerPublisher = timerPublisher
            .sink { [weak self] _ in
                self?.handleTimerUpdates()
            }
    }

    deinit {
        cancellableTimerPublisher?.cancel()
    }
}

// MARK: Audio Processing

public extension Mixalicious {
    /// Add an audio asset to a video asset at insertionTime
    ///
    /// The `audio` asset provided will have its audio track inserted into the target asset
    ///
    /// - Important: The `audio` asset must contain audio only
    ///
    /// - Note: The video will be returned as an `mp4` file
    ///
    /// ```swift
    /// // Creates a video asset with audio inserted at CMTime.zero
    /// let videoURL = try await insert(audio: audioAsset, target: targetAsset)
    /// ```
    ///
    ///  ```swift
    /// // Creates a video asset with audio inserted at 60.0
    /// let videoURL = try await insert(audio: audioAsset, target: targetAsset, insertionTime: 60.0)
    /// ```
    ///
    /// - Parameters:
    ///   - audio: `AVAsset` **only** containing audio to insert
    ///   - target: `AVAsset` containing audio or video for audio to be inserted into
    ///   - insertionTime: Optional `CMTime` for where to start the audio. Default is `CMTime.zero`
    /// - Returns: `URL` for the completed file
    func insert(audio: AVAsset,
                target: AVAsset,
                insertionTime: CMTime = .zero) async throws -> URL {
        defer {
            stopProgressUpdates()
        }

        var mediaType: MediaType

        if target.isAudioOnly {
            mediaType = .audio
        } else if target.hasVideoTrack {
            mediaType = .video
        } else {
            throw (MixaliciousError.unknownFileType)
        }

        guard audio.isAudioOnly else {
            throw (MixaliciousError.audioTrackNotFound)
        }

        guard insertionTime >= .zero,
              insertionTime <= target.timeRange.end
        else {
            throw (MixaliciousError.invalidInsertionTime)
        }

        startProgressUpdates()

        return try await insertAudio.insert(to: target,
                                            with: audio,
                                            mediaType: mediaType,
                                            insertionTime: insertionTime,
                                            progress: progress)
    }

    /// Extracts the audio track from the provided asset into a new file
    ///
    /// - Important: The `video` asset must contain an audio track
    ///
    /// - Note: The audio will be returned as an `m4a` file
    ///
    /// ```swift
    /// let audioURL = try await extractAudio(video: videoAsset)
    /// ```
    ///
    /// - Parameter video: `AVAsset` containing source to extract audio from
    /// - Returns: `URL` for the completed file
    func extractAudio(video: AVAsset) async throws -> URL {
        defer {
            stopProgressUpdates()
        }

        guard video.hasAudioTrack else {
            throw (MixaliciousError.audioTrackNotFound)
        }

        startProgressUpdates()

        return try await extractAudio.extract(video: video,
                                              progress: progress)
    }
}

// MARK: Trim Processing

public extension Mixalicious {
    /// Trims the provided asset. This works for audio and video
    ///
    /// - Note: This does not mutate the original asset
    ///
    /// ```swift
    /// let url = try await trim(asset: asset, timeRange: timeRange)
    /// ```
    ///
    /// - Parameters:
    ///   - asset: An audio or video `AVAsset` to trim
    ///   - timeRange: CMTimeRange for where to begin and end trimming of asset
    ///   - progress: Used to track export process
    /// - Returns: `URL` for the completed file
    func trim(asset: AVAsset,
              timeRange: CMTimeRange) async throws -> URL {
        try await trim(asset: asset,
                       start: timeRange.start,
                       end: timeRange.end)
    }

    /// Trims the provided asset. This works for audio and video
    ///
    /// - Note: This does not mutate the original asset
    ///
    /// ```swift
    /// let url = try await trim(asset: asset, start: .zero, end: 60.0)
    /// ```
    ///
    /// - Parameters:
    ///   - asset: An audio or video `AVAsset` to trim
    ///   - start: Where to begin  trimming of asset
    ///   - end: Where to end trimming of asset
    /// - Returns: `URL` for the completed file
    func trim(asset: AVAsset,
              start: CMTime,
              end: CMTime) async throws -> URL {
        defer {
            stopProgressUpdates()
        }

        var mediaType: MediaType

        if asset.isAudioOnly {
            mediaType = .audio
        } else if asset.hasVideoTrack {
            mediaType = .video
        } else {
            throw (MixaliciousError.unknownFileType)
        }

        guard start >= .zero,
              end <= asset.timeRange.end
        else {
            throw (MixaliciousError.invalidInsertionTime)
        }

        guard start <= end else {
            throw (MixaliciousError.invalidStartEndTimeOrder)
        }

        let timeRange = CMTimeRange(start: start,
                                    end: end)
        startProgressUpdates()

        return try await trimAsset.trim(asset: asset,
                                        mediaType: mediaType,
                                        timeRange: timeRange,
                                        progress: progress)
    }
}

// MARK: Scale Processing

public extension Mixalicious {
    /// Adjusts the timescale in the provided audio asset to support slowing or speeding up its playback
    ///
    /// This will affect the audio portion of the asset, producing an audio track upon completion. This function
    /// supports scaling the audio in an included video track as well, but will not return a video.
    ///
    /// - Note: This does not mutate the original asset
    ///
    /// - Important: The `multiplier` argument must be a positive, non-zero value
    ///
    /// ```swift
    /// // Speed up the asset
    /// let url = try await scaleAudio(asset: asset, multiplier: 0.25)
    /// ```
    ///
    /// ```swift
    /// // Slow down the asset
    /// let url = try await scaleAudio(asset: asset, multiplier: 3.0)
    /// ```
    ///
    /// - Parameters:
    ///   - asset: An audio or video with sound `AVAsset` to scale
    ///   - multiplier: Positive, non-zero value to adjust playback speed by
    /// - Returns: `URL` for the completed file
    func scaleAudio(asset: AVAsset,
                    multiplier: Float64) async throws -> URL {
        defer {
            stopProgressUpdates()
        }

        guard asset.hasAudioTrack else {
            throw (MixaliciousError.audioTrackNotFound)
        }

        return try await scale(asset: asset,
                               multiplier: multiplier,
                               isAudioIncluded: true,
                               mediaType: .audio)
    }

    /// Adjusts the timescale in the provided video asset to support slowing or speeding up its playback
    ///
    /// Including the audio track is optional, indicated by the `isAudioIncluded` argument. When set to `false`,
    /// you will only receive a video asset with no audio track.
    ///
    /// - Note: This does not mutate the original asset
    ///
    /// - Important: The `multiplier` argument must be a positive, non-zero value
    ///
    /// ```swift
    /// // Speed up the asset
    /// let url = try await scaleVideo(asset: asset, multiplier: 0.25, isAudioIncluded: true)
    /// ```
    ///
    /// ```swift
    /// // Slow down the asset
    /// let url = try await scaleVideo(asset: asset, multiplier: 3.0, isAudioIncluded: false)
    /// ```
    ///
    /// - Parameters:
    ///   - asset: An audio or video with sound `AVAsset` to scale
    ///   - multiplier: Positive, non-zero value to adjust playback speed by
    ///   - isAudioIncluded: Indicate if the video's audio should be scaled and added to the output
    /// - Returns: `URL` for the completed file
    func scaleVideo(asset: AVAsset,
                    multiplier: Float64,
                    isAudioIncluded: Bool) async throws -> URL {
        defer {
            stopProgressUpdates()
        }

        guard asset.hasVideoTrack else {
            throw (MixaliciousError.videoTrackNotFound)
        }

        return try await scale(asset: asset,
                               multiplier: multiplier,
                               isAudioIncluded: isAudioIncluded,
                               mediaType: .video)
    }
}

// MARK: Combine Processing

public extension Mixalicious {
    /// Combines a given array of audio containing assets into a single audio file
    ///
    /// The assets will be connected in the order they are received
    ///
    /// - Important: Video assets can be used, but only their audio will be used
    ///
    /// - Note: The audio will be returned as an `m4a` file
    ///
    /// ```swift
    /// let audioURL = try await combineAudio(assets: assets)
    /// ```
    ///
    /// - Parameter assets: `AVAsset`s containing source to combine audio from
    /// - Returns: `URL` for the completed file
    func combineAudio(assets: [AVAsset]) async throws -> URL {
        try await combine(assets: assets, mediaType: .audio)
    }

    /// Combines a given array of video assets into a single video
    ///
    /// The assets will be connected in the order they are received
    ///
    /// - Important: All assets must contain video tracks
    ///
    /// - Note: The video will be returned as an `mp4` file
    ///
    /// ```swift
    /// let videoURL = try await combineVideo(assets: assets)
    /// ```
    ///
    /// - Parameter assets: `AVAsset`s containing source to combine video from
    /// - Returns: `URL` for the completed file
    func combineVideo(assets: [AVAsset]) async throws -> URL {
        try await combine(assets: assets, mediaType: .video)
    }
}

// MARK: Private functions

private extension Mixalicious {
    /// Called by timer to update `completionPercent` publisher
    func handleTimerUpdates() {
        completionPercent = progress.fractionCompleted
    }

    /// Called when an operation begins. Resets progress and starts timer
    func startProgressUpdates() {
        progress.reset()
        completionPercent = 0.0
        cancellableTimerPublisher = timerPublisher.connect()
    }

    /// Called when an operation ends. Resets progress and cancels timer
    func stopProgressUpdates() {
        completionPercent = 1.0
        cancellableTimerPublisher?.cancel()
    }

    /// Attempts to combine a collection of assets into a single asset of the desired type
    /// - Parameters:
    ///   - assets: Audio or video assets to combine
    ///   - mediaType: File type to export
    /// - Returns: `URL` for the completed file
    func combine(assets: [AVAsset],
                 mediaType: MediaType) async throws -> URL {
        defer {
            stopProgressUpdates()
        }

        guard !assets.isEmpty else {
            throw (MixaliciousError.assetsArrayIsEmpty)
        }

        switch mediaType {
        case .audio:
            guard !assets.contains(where: { !$0.hasAudioTrack })
            else {
                throw (MixaliciousError.audioTrackNotFound)
            }

        case .video:
            guard !assets.contains(where: { !$0.hasVideoTrack })
            else {
                throw (MixaliciousError.videoTrackNotFound)
            }
        }

        startProgressUpdates()

        return try await combineAssets.combine(assets: assets,
                                               mediaType: mediaType,
                                               progress: progress)
    }

    /// Adjusts the timescale in the provided asset to support slowing or speeding up its playback
    /// - Parameters:
    ///   - asset: An audio or video with sound `AVAsset` to scale
    ///   - multiplier: Positive, non-zero value to adjust playback speed by
    ///   - isAudioIncluded: Indicate if the video's audio should be scaled and added to the output
    ///   - mediaType: File type to export
    /// - Returns: `URL` for the completed file
    private func scale(asset: AVAsset,
                       multiplier: Float64,
                       isAudioIncluded: Bool,
                       mediaType: MediaType) async throws -> URL {
        guard multiplier > 0 else {
            throw (MixaliciousError.unsupportedValue)
        }

        startProgressUpdates()

        return try await scaleAsset.scale(asset: asset,
                                          multiplier: multiplier,
                                          isAudioIncluded: isAudioIncluded,
                                          mediaType: mediaType,
                                          progress: progress)
    }
}
