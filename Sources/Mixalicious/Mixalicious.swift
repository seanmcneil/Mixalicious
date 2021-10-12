import AVFoundation
import Combine
import SwiftUI

public final class Mixalicious: ObservableObject {
    /// The percentage of the operation completed, on a 0.0...1.0 scale
    @Published private(set) var completionPercent = 0.0

    private let insertAudio = InsertAudio()
    private let extractAudio = ExtractAudio()
    private let trimAsset = TrimAsset()
    private let combineVideos = CombineVideos()

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

    // MARK: Audio Processing

    /// Add an audio asset to a video asset at insertionTime
    ///
    /// - Note: The video will be returned as an mp4 file
    ///
    /// - Parameters:
    ///   - audio: AVAsset containing audio
    ///   - video: AVAsset containing video
    ///   - insertionTime: Optional CMTime for where to start the audio. Default is CMTime.zero
    /// - Returns: URL for completed video, or MixaliciousError if the operation failed
    public func insert(audio: AVAsset,
                       target: AVAsset,
                       insertionTime: CMTime = .zero) -> AnyPublisher<URL, MixaliciousError> {
        var mediaType: MediaType

        if target.isAudioOnly {
            mediaType = .audio
        } else if target.hasVideoTrack {
            mediaType = .video
        } else {
            return Fail(error: .unknownFileType)
                .eraseToAnyPublisher()
        }

        guard audio.isAudioOnly else {
            return Fail(error: .audioTrackNotFound)
                .eraseToAnyPublisher()
        }

        guard insertionTime >= .zero,
              insertionTime <= target.timeRange.end
        else {
            return Fail(error: .invalidInsertionTime)
                .eraseToAnyPublisher()
        }

        startProgressUpdates()

        return insertAudio.insert(to: target,
                                  with: audio,
                                  mediaType: mediaType,
                                  insertionTime: insertionTime,
                                  progress: progress)
            .last()
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] url -> AnyPublisher<URL, MixaliciousError> in
                assert(Thread.isMainThread, "Should receive on main")

                self?.stopProgressUpdates()

                return Just(url)
                    .setFailureType(to: MixaliciousError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// Extracts the audio track from the provided video into a new m4a file
    ///
    /// - Note: This does not mutate the video file
    ///
    /// - Parameters:
    ///   - video: AVAsset containing video to extract audio from
    /// - Returns: URL for completed video, or MixaliciousError if the operation failed
    public func extractAudio(video: AVAsset) -> AnyPublisher<URL, MixaliciousError> {
        guard video.isAudioAndVideoPresent else {
            return Fail(error: .videoTrackNotFound)
                .eraseToAnyPublisher()
        }

        startProgressUpdates()

        return extractAudio.extract(video: video,
                                    progress: progress)
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] url -> AnyPublisher<URL, MixaliciousError> in
                assert(Thread.isMainThread, "Should receive on main")

                self?.stopProgressUpdates()

                return Just(url)
                    .setFailureType(to: MixaliciousError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // MARK: General Processing

    /// Trims the provided asset. This works for audio and video
    ///
    /// - Note: This does not mutate the original asset
    ///
    /// - Parameters:
    ///   - asset: AVAsset to trim. Can be audio or video
    ///   - timeRange: CMTimeRange for where to begin and end trimming of asset
    ///   - progress: Progress used to track export process
    /// - Returns: Either the URL of the trimmed asset, or an error if the operation failed
    public func trim(asset: AVAsset,
                     timeRange: CMTimeRange) -> AnyPublisher<URL, MixaliciousError> {
        trim(asset: asset,
             start: timeRange.start,
             end: timeRange.end)
    }

    /// Trims the provided asset. This works for audio and video
    ///
    /// - Note: This does not mutate the original asset
    ///
    /// - Parameters:
    ///   - asset: AVAsset to trim. Can be audio or video
    ///   - start: CMTime for where to begin  trimming of asset
    ///   - end: CMTime for where to end trimming of asset
    ///   - progress: Progress used to track export process
    /// - Returns: Either the URL of the trimmed asset, or an error if the operation failed
    public func trim(asset: AVAsset,
                     start: CMTime,
                     end: CMTime) -> AnyPublisher<URL, MixaliciousError> {
        var mediaType: MediaType

        if asset.isAudioOnly {
            mediaType = .audio
        } else if asset.hasVideoTrack {
            mediaType = .video
        } else {
            return Fail(error: .unknownFileType)
                .eraseToAnyPublisher()
        }

        guard start >= .zero,
              start <= end,
              end <= asset.timeRange.end
        else {
            return Fail(error: .invalidInsertionTime)
                .eraseToAnyPublisher()
        }

        let timeRange = CMTimeRange(start: start,
                                    end: end)
        startProgressUpdates()

        return trimAsset.trim(asset: asset,
                              mediaType: mediaType,
                              timeRange: timeRange,
                              progress: progress)
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] url -> AnyPublisher<URL, MixaliciousError> in
                assert(Thread.isMainThread, "Should receive on main")

                self?.stopProgressUpdates()

                return Just(url)
                    .setFailureType(to: MixaliciousError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// Connects the provided AVAssets together to form a single video
    ///
    /// - Note: The videos will be connected in the order they are received
    ///         If the videos array contains any non-video assets, it will fail
    ///
    /// - Parameters:
    ///   - videos: [AVAsset] that are connected in order to form a single video
    ///   - progress: Progress used to track export process
    /// - Returns: Either the URL of the combined asset, or an error if the operation failed
    public func combineVideos(videos: [AVAsset]) -> AnyPublisher<URL, MixaliciousError> {
        guard !videos.isEmpty,
              !videos.contains(where: { !$0.hasVideoTrack })
        else {
            return Fail(error: .videoTrackNotFound)
                .eraseToAnyPublisher()
        }

        startProgressUpdates()

        return combineVideos.combine(videos: videos,
                                     progress: progress)
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] url -> AnyPublisher<URL, MixaliciousError> in
                assert(Thread.isMainThread, "Should receive on main")

                self?.stopProgressUpdates()

                return Just(url)
                    .setFailureType(to: MixaliciousError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // MARK: Private functions

    /// Called by timer to update completionPercent publisher
    private func handleTimerUpdates() {
        completionPercent = progress.fractionCompleted
    }

    /// Called when an operation begins. Resets progress and starts timer
    private func startProgressUpdates() {
        progress.reset()
        completionPercent = 0.0
        cancellableTimerPublisher = timerPublisher.connect()
    }

    /// Called when an operation ends. Resets progress and cancels timer
    private func stopProgressUpdates() {
        completionPercent = 1.0
        cancellableTimerPublisher?.cancel()
    }
}
