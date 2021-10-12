import AVFoundation
import Combine

protocol WriteAssetProtocol: AnyObject {
    var cancelleables: Set<AnyCancellable> { get set }

    func write(asset: AVAsset,
               mediaType: MediaType,
               progress: Progress,
               timeRange: CMTimeRange?) -> AnyPublisher<URL, MixaliciousError>
}

extension WriteAssetProtocol {
    func write(asset: AVAsset,
               mediaType: MediaType,
               progress: Progress,
               timeRange: CMTimeRange? = nil) -> AnyPublisher<URL, MixaliciousError> {
        // It is possible some assets have no tracks
        guard !asset.tracks.isEmpty else {
            return Fail(error: .assetTrackIsEmpty)
                .eraseToAnyPublisher()
        }

        guard let session = AVAssetExportSession(asset: asset,
                                                 presetName: mediaType.presetName)
        else {
            return Fail(error: .failedToCreateSession)
                .eraseToAnyPublisher()
        }

        guard let outputURL = URL(mediaType: mediaType) else {
            return Fail(error: .failedToCreateFile)
                .eraseToAnyPublisher()
        }

        if let timeRange = timeRange {
            session.timeRange = timeRange
        }

        let sessionWriter = SessionWriter()
        session.outputURL = outputURL
        session.outputFileType = mediaType.fileType

        return sessionWriter.export(session: session,
                                    mediaType: mediaType,
                                    outputURL: outputURL,
                                    progress: progress)
            .subscribe(on: DispatchQueue.global(qos: .utility), options: nil)
            .eraseToAnyPublisher()
    }
}
