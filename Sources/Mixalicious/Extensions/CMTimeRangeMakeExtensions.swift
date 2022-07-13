import CoreMedia

extension CMTimeRange {
    /// Make a valid CMTimeRange with start of 0 and duration
    /// - Parameter duration: Initializes the duration field of the resulting CMTimeRange
    init(duration: CMTime) {
        self.init(start: .zero,
                  duration: duration)
    }
}
