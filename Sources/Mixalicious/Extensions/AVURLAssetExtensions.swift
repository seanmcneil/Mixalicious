import AVFoundation

public extension AVURLAsset {
    private static var byteCountFormatter = ByteCountFormatter()

    private static var dateComponentsFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.default]

        return formatter
    }

    /// Provides a string with the file size properly formatted for KB/MB/GB
    var size: String? {
        if let fileSize = fileSize {
            return (AVURLAsset.byteCountFormatter.string(fromByteCount: Int64(fileSize)))
        }

        return nil
    }

    /// Provides a string with the time properly formatted for the current locale
    var time: String? {
        AVURLAsset.dateComponentsFormatter.string(from: duration.seconds)
    }
}

extension AVURLAsset {
    var fileSize: Int? {
        let keys: Set<URLResourceKey> = [.totalFileSizeKey, .fileSizeKey]
        let resourceValues = try? url.resourceValues(forKeys: keys)

        return resourceValues?.fileSize ?? resourceValues?.totalFileSize
    }
}
