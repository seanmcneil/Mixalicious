import AVFoundation
import Foundation

final class ExtractAudio {
    /// Extracts the audio track, if available, from the provided video asset
    ///
    /// - Note: Video is not mutated
    ///
    /// - Parameters:
    ///   - video: ``AVAsset`` for video to extract audio from
    ///   - progress: Responsible for tracking export process and reporting status
    /// - Returns: ``URL`` of extracted audio file
    func extract(video: AVAsset,
                 progress: Progress) async throws -> URL {
        let composition = AVMutableComposition()
        let mutableComposition = try await createCompositionTrack(mediaType: .audio,
                                                                  asset: video,
                                                                  composition: composition)

        return try await write(asset: mutableComposition,
                               mediaType: .audio,
                               progress: progress)
    }
}

extension ExtractAudio: AudioProcessingProtocol {}
