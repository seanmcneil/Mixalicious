import AVFoundation
import Combine
import Foundation

final class ExtractAudio {
    /// Supports sink usage with write operation
    var cancelleables = Set<AnyCancellable>()

    deinit {
        cancelleables.forEach { cancelleable in
            cancelleable.cancel()
        }
    }

    /// Extracts the audio track, if available, from the provided video asset
    ///
    /// - Note: Video is not mutated
    ///
    /// - Parameters:
    ///   - video: AVAsset for video to extract audio from
    ///   - progress: Progress used to track export process
    /// - Returns: Either the URL of the extracted audio, or an error if the operation failed
    func extract(video: AVAsset,
                 progress: Progress) -> AnyPublisher<URL, MixaliciousError> {
        let composition = AVMutableComposition()

        return createCompositionTrack(mediaType: .audio,
                                      asset: video,
                                      composition: composition)
            .flatMap { [weak self] mutableComposition -> AnyPublisher<URL, MixaliciousError> in
                guard let strongSelf = self else {
                    return Fail(error: .outOfScope)
                        .eraseToAnyPublisher()
                }

                return strongSelf.write(asset: mutableComposition,
                                        mediaType: .audio,
                                        progress: progress)
            }
            .eraseToAnyPublisher()
    }
}

extension ExtractAudio: AudioProcessingProtocol {}
