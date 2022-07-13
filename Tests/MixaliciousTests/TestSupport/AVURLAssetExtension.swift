import AVFoundation

extension AVURLAsset {
    /// Produces a time range for the middle half of the asset
    var midDuration: CMTimeRange {
        // Calculate start time at 25% into asset
        let startTime = duration.seconds * 0.25
        // Calculate start time at 75% into asset
        let endTime = duration.seconds * 0.75
        // Create start & end times using asset's timescale
        let start = CMTime(seconds: startTime,
                           preferredTimescale: duration.timescale)
        let end = CMTime(seconds: endTime,
                         preferredTimescale: duration.timescale)

        return CMTimeRange(start: start,
                           end: end)
    }
}
