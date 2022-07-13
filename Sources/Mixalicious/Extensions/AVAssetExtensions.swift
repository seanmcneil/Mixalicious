import AVFoundation

extension AVAsset {
    /// Indicates if the asset only contains audio tracks
    var isAudioOnly: Bool {
        !tracks.isEmpty && tracks.filter { $0.mediaType == .audio }.count == tracks.count
    }

    /// Indicates if the asset contains audio and video tracks
    var isAudioAndVideoPresent: Bool {
        hasAudioTrack && hasVideoTrack
    }

    /// Indicates if the asset contains one or more audio tracks
    var hasAudioTrack: Bool {
        tracks.contains(where: { $0.mediaType == .audio })
    }

    /// Indicates if the asset contains one or more video tracks
    var hasVideoTrack: Bool {
        tracks.contains(where: { $0.mediaType == .video })
    }

    /// Duration for the current asset
    var timeRange: CMTimeRange {
        CMTimeRange(duration: duration)
    }
}
