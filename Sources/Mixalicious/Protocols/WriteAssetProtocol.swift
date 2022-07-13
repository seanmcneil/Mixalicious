import AVFoundation

protocol WriteAssetProtocol: AnyObject {
    func write(asset: AVAsset,
               mediaType: MediaType,
               progress: Progress,
               timeRange: CMTimeRange?) async throws -> URL
}

extension WriteAssetProtocol {
    func write(asset: AVAsset,
               mediaType: MediaType,
               progress: Progress,
               timeRange: CMTimeRange? = nil) async throws -> URL {
        // It is possible some assets have no tracks
        guard !asset.tracks.isEmpty else {
            throw (MixaliciousError.assetTrackIsEmpty)
        }

        guard let session = AVAssetExportSession(asset: asset,
                                                 presetName: mediaType.presetName)
        else {
            throw (MixaliciousError.failedToCreateSession)
        }

        guard let outputURL = URL(mediaType: mediaType) else {
            throw (MixaliciousError.failedToCreateFile)
        }

        if let timeRange = timeRange {
            session.timeRange = timeRange
        }

        let sessionWriter = SessionWriter()
        session.outputURL = outputURL
        session.outputFileType = mediaType.fileType

        return try await sessionWriter.export(session: session,
                                              outputURL: outputURL,
                                              progress: progress)
    }
}
