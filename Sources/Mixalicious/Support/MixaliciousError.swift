import Foundation

/// Library specific implementations for various errors that can be encountered during export preparation and output
public enum MixaliciousError: Error {
    /// Attempting to combine an array of `AVAsset` that is empty
    case assetsArrayIsEmpty

    /// Attempting to write an `AVAsset` that does not contain tracks
    case assetTrackIsEmpty

    /// Performing an operation that requires an `AVAsset` with audio that is not present
    case audioTrackNotFound

    /// Performing an export operation and encountering a `cancelled` error
    case exportCancelled

    /// Performing an export operation and encountering an `exporting` error
    case exportExporting

    /// Performing an export operation and encountering a `failed` error
    case exportFailed

    /// Performing an export operation and encountering an `unknown` error
    case exportUnknown

    /// Performing an export operation and encountering a `waiting` error
    case exportWaiting

    /// Attempting to create an audio track, but no audio was found
    case failedToCreateAudioTrack

    /// Unable to generate a valid `url` for writing the output
    case failedToCreateFile

    /// Unable to create the `AVAssetExportSession` for exporting asset
    case failedToCreateSession

    /// Attempting to create a video track, but no video was found
    case failedToCreateVideoTrack

    /// Attempting to insert a track into an asset but failing on the `insertTimeRange` operation
    case failedToInsertTimeRange

    /// The provided insertion times are not within the given asset's time range
    case invalidInsertionTime

    /// The provided insertion time has `end` before `start`
    case invalidStartEndTimeOrder

    /// An unsupported asset type is provided that cannot be handled
    case unknownFileType

    /// An unsupported negative or 0 value was provided
    case unsupportedValue

    /// Performing an operation that requires an `AVAsset` with video that is not present
    case videoTrackNotFound
}
