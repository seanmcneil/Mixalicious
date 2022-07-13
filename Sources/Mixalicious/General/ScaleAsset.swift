import AVFoundation

final class ScaleAsset {
    private let preferredTrackID = Int32(kCMPersistentTrackID_Invalid)

    func scale(asset: AVAsset,
               multiplier: Float64,
               isAudioIncluded: Bool,
               mediaType: MediaType,
               progress: Progress) async throws -> URL {
        precondition(multiplier > 0.0)

        let mixComposition = AVMutableComposition()
        // Scale the duration for audio and video tracks
        let scaledDuration = CMTimeMultiplyByFloat64(asset.duration,
                                                     multiplier: multiplier)
        if asset.hasVideoTrack {
            try scaleVideo(mixComposition: mixComposition,
                           asset: asset,
                           scaledDuration: scaledDuration)
        }

        if isAudioIncluded {
            try scaleAudio(mixComposition: mixComposition,
                           asset: asset,
                           scaledDuration: scaledDuration)
        }

        return try await write(asset: mixComposition,
                               mediaType: mediaType,
                               progress: progress)
    }

    private func scaleVideo(mixComposition: AVMutableComposition,
                            asset: AVAsset,
                            scaledDuration: CMTime) throws {
        guard let videoTrack = asset.tracks(withMediaType: .video).first,
              let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: .video,
                                                                         preferredTrackID: preferredTrackID),
              let assetVideoTrack = asset.tracks(withMediaType: .video).first else {
            throw (MixaliciousError.videoTrackNotFound)
        }

        let timeRange = asset.timeRange
        // Insert existing video track at the start of the composition
        do {
            try compositionVideoTrack.insertTimeRange(timeRange,
                                                      of: assetVideoTrack,
                                                      at: .zero)
        } catch {
            throw (MixaliciousError.failedToInsertTimeRange)
        }

        compositionVideoTrack.scaleTimeRange(timeRange,
                                             toDuration: scaledDuration)

        // Keep original transformation
        compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
    }

    private func scaleAudio(mixComposition: AVMutableComposition,
                            asset: AVAsset,
                            scaledDuration: CMTime) throws {
        guard asset.hasAudioTrack else {
            throw (MixaliciousError.audioTrackNotFound)
        }

        if let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: .audio,
                                                                      preferredTrackID: preferredTrackID) {
            let timeRange = asset.timeRange
            // Iterate through each audio track and insert it at the start
            for assetAudioTrack in asset.tracks(withMediaType: .audio) {
                do {
                    try compositionAudioTrack.insertTimeRange(timeRange,
                                                              of: assetAudioTrack,
                                                              at: .zero)
                } catch {
                    throw (MixaliciousError.failedToInsertTimeRange)
                }
            }
            compositionAudioTrack.scaleTimeRange(timeRange,
                                                 toDuration: scaledDuration)
        }
    }
}

extension ScaleAsset: WriteAssetProtocol {}
