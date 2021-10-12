import AVFoundation

extension AVAsset {
    /// Bool indicating if the asset only contains audio tracks
    var isAudioOnly: Bool {
        !tracks.isEmpty && tracks.filter { $0.mediaType == .audio }.count == tracks.count
    }

    /// Bool indicating if the asset contains audio and video tracks
    var isAudioAndVideoPresent: Bool {
        hasAudioTrack && hasVideoTrack
    }

    /// Bool indicating if the asset contains one or more audio tracks
    var hasAudioTrack: Bool {
        tracks.contains(where: { $0.mediaType == .audio })
    }

    /// Bool indicating if the asset contains one or more video tracks
    var hasVideoTrack: Bool {
        tracks.contains(where: { $0.mediaType == .video })
    }

    /// CMTimeRange for the current asset
    var timeRange: CMTimeRange {
        CMTimeRangeMake(start: .zero,
                        duration: duration)
    }
}
