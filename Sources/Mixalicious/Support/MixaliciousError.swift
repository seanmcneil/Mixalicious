import Foundation

public enum MixaliciousError: Swift.Error {
    case assetTrackIsEmpty
    case audioTrackNotFound
    case exportCancelled
    case exportExporting
    case exportFailed
    case exportUnknown
    case exportWaiting
    case failedToCreateAudioTrack
    case failedToCreateFile
    case failedToCreateSession
    case failedToCreateVideoTrack
    case failedToInsertTimeRange
    case invalidInsertionTime
    case outOfScope
    case startAfterEnd
    case timeOutOfRange
    case unknown
    case unknownFileType
    case videoTrackNotFound
}
