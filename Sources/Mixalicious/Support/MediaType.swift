import AVFoundation

enum MediaType {
    case audio
    case video

    var fileExtension: String {
        switch self {
        case .audio:
            return "m4a"

        case .video:
            return "mp4"
        }
    }

    var fileType: AVFileType {
        switch self {
        case .audio:
            return .m4a

        case .video:
            return .mp4
        }
    }

    var folderName: String {
        String(describing: self)
    }

    var presetName: String {
        switch self {
        case .audio:
            return AVAssetExportPresetAppleM4A

        case .video:
            return AVAssetExportPresetHighestQuality
        }
    }

    var type: AVMediaType {
        switch self {
        case .audio:
            return .audio

        case .video:
            return .video
        }
    }
}
