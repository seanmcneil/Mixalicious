# Mixalicious

A simple library for modifying audio and video AVAssets.

## Requirements
- iOS 13
- macOS 10.15
- Xcode 12

## Installing

### Swift Package Manager

If you are adding Mixalicious as a dependency, you can use the following:

```swift
dependencies: [
    .package(url: "https://github.com/seanmcneil/Mixalicious.git", 
    from: "1.0.0")
]
```

### Usage

The API for Mixalicious is built atop SwiftUI and Combine.
- All functions return  `AnyPublisher<URL, MixaliciousError>`
- The current progress of the export is updated via a `Published` property named `completionPercent`

Mixalicious provides the following functionality:
- `insert(audio:target:insertionTime:)`
- `extractAudio(video:)`
- `trim(asset:timeRange:)`
- `trim(asset:start:end:)`
- `combine(videos:)`

#### Insert

Insert supports adding an audio `AVAsset` to a target `AVAsset` that can be an audio or video asset. If no `insertionTime` is provided, then it will insert the audio track at `CMTime.zero`.

***Example***
```swift
// Using default insertionTime of .zero
let mixalicious = Mixalicious()
let audio = AVURLAsset(url: ...)
let video = AVURLAsset(url: ...)
mixalicious.insert(audio: audio,
                   target: video)
// Apply a sink or other Combine operation to obtain url value
```

```swift
// Using provided insertionTime
let mixalicious = Mixalicious()
let audio = AVURLAsset(url: ...)
let video = AVURLAsset(url: ...)
let insertionTime = CMTime(value: 30, timescale: 600)
mixalicious.insert(audio: audio,
                   target: video,
                   insertionTime: insertionTime)
// Apply a sink or other Combine operation to obtain url value
```

#### Extract

Extract supports extracting the audio track from the given video `AVAsset`. This does not mutate the video asset.

***Example***
```swift
let mixalicious = Mixalicious()
let video = AVURLAsset(url: ...)
mixalicious.extractAudio(video: video)
// Apply a sink or other Combine operation to obtain url value
```

#### Trim

Trim will take the provided `AVAsset` and trim it using the range you provide. This can be done with a `start` and `end` time of `CMTime`, or using a `timeRange` of `CMTimeRange`.

***Example***
```swift
let mixalicious = Mixalicious()
let video = AVURLAsset(url: ...)
mixalicious.extractAudio(video: video)
// Apply a sink or other Combine operation to obtain url value
```

#### Combine

Combine will take an array of `AVAsset` that represent videos and connect them in the order provided through the `videos` array.

### Properties

Several useful properties extended from `AVURLAsset` are exposed as well for displaying information on assets.

#### Size

A `public` property `size` is exposed, which is a `String` representing the file size of the asset. A `ByteCountFormatter` is used to format this, providing a `String` with `KB`, `MB` and `GB` appended to the size.

***Example***
```swift
let asset = AVURLAsset(url: ...)
print(asset.size) /// "15 MB"
```

#### Time

A `public` property `time` is exposed, which is a `String` representing the duration of the asset. A `DateComponentsFormatter` is used to format this, providing a `String` with the time in seconds, minutes, or hours.

***Example***
```swift
let asset = AVURLAsset(url: ...)
print(asset.time) /// "1:14"
```

### Errors

Mixalicious provides a wide assortment of errors that can assist you in troubleshooting.

```swift
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
```

### Test Coverage

Mixalicious includes several asset files to support unit tests. Currently, the library has approximately 93% test coverage.

### Support

If you find an issue or can think of an improvement, issues and pull requests are always welcome. 

For pull requests, please be sure to ensure your work is covered with existing or new unit tests.

### Test Data

The included test data is produced by NASA and belongs to the public domain.

## Author

Sean McNeil

## License

Mixalicious is available under the MIT license. See the LICENSE file for more info.
