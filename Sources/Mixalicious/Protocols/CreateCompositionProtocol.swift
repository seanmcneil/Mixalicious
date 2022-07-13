import AVFoundation

protocol CreateCompositionProtocol: AnyObject {
    func createCompositionTrack(mediaType: MediaType,
                                asset: AVAsset,
                                timeRange: CMTimeRange?,
                                insertionTime: CMTime,
                                composition: AVMutableComposition) async throws -> AVMutableComposition
}

extension CreateCompositionProtocol {
    @discardableResult
    func createCompositionTrack(mediaType: MediaType,
                                asset: AVAsset,
                                timeRange: CMTimeRange? = nil,
                                insertionTime: CMTime = .zero,
                                composition: AVMutableComposition) async throws -> AVMutableComposition {
        let mutableTrack = composition.addMutableTrack(withMediaType: mediaType.type,
                                                       preferredTrackID: kCMPersistentTrackID_Invalid)

        guard let assetTrack = asset.tracks(withMediaType: mediaType.type)
            .first
        else {
            switch mediaType {
            case .audio:
                throw (MixaliciousError.failedToCreateAudioTrack)

            case .video:
                throw (MixaliciousError.failedToCreateVideoTrack)
            }
        }

        do {
            switch mediaType {
            case .audio:
                // Because it is possible that multiple audio tracks exist, this
                // loops through all audio tracks to layer them into one track.
                for audioTrack in asset.tracks(withMediaType: mediaType.type) {
                    try mutableTrack?.insertTimeRange(timeRange ?? asset.timeRange,
                                                      of: audioTrack,
                                                      at: insertionTime)
                }

            case .video:
                try mutableTrack?.insertTimeRange(timeRange ?? asset.timeRange,
                                                  of: assetTrack,
                                                  at: insertionTime)
            }
        } catch {
            throw (MixaliciousError.failedToInsertTimeRange)
        }

        return composition
    }
}
