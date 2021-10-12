import AVFoundation
import Combine

protocol CreateCompositionProtocol: AnyObject {
    func createCompositionTrack(mediaType: MediaType,
                                asset: AVAsset,
                                timeRange: CMTimeRange?,
                                insertionTime: CMTime,
                                composition: AVMutableComposition) -> AnyPublisher<AVMutableComposition, MixaliciousError>
}

extension CreateCompositionProtocol {
    func createCompositionTrack(mediaType: MediaType,
                                asset: AVAsset,
                                timeRange: CMTimeRange? = nil,
                                insertionTime: CMTime = .zero,
                                composition: AVMutableComposition) -> AnyPublisher<AVMutableComposition, MixaliciousError> {
        Future<AVMutableComposition, MixaliciousError> { promise in
            let mutableTrack = composition.addMutableTrack(withMediaType: mediaType.type,
                                                           preferredTrackID: kCMPersistentTrackID_Invalid)

            guard let assetTrack = asset.tracks(withMediaType: mediaType.type)
                .first
            else {
                var error: MixaliciousError
                switch mediaType {
                case .audio:
                    error = .failedToCreateAudioTrack

                case .video:
                    error = .failedToCreateVideoTrack
                }
                promise(.failure(error))

                return
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
                promise(.failure(.failedToInsertTimeRange))
            }

            promise(.success(composition))
        }
        .eraseToAnyPublisher()
    }
}
