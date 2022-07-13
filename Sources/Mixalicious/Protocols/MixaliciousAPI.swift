import AVFoundation

/// Supports mocking of the library in client app
public protocol MixaliciousAPI {
    var completionPercent: Double { get }

    func insert(audio: AVAsset,
                target: AVAsset,
                insertionTime: CMTime) async throws -> URL
    func extractAudio(video: AVAsset) async throws -> URL
    func trim(asset: AVAsset,
              timeRange: CMTimeRange) async throws -> URL
    func trim(asset: AVAsset,
              start: CMTime,
              end: CMTime) async throws -> URL
    func combineAudio(assets: [AVAsset]) async throws -> URL
    func combineVideo(assets: [AVAsset]) async throws -> URL
}
