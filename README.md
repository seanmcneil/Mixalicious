# Mixalicious

A simple library for modifying audio and video AVAssets.

## Requirements
- iOS 13
- tvOS 13
- macOS 10.15
- Xcode 13

## Installing

### Swift Package Manager

If you are adding Mixalicious as a dependency, you can use the following:

```swift
// For async based version & additional functionality
dependencies: [
    .package(url: "https://github.com/seanmcneil/Mixalicious.git", 
    from: "2.0.0")
]

// For Combine based version
dependencies: [
    .package(url: "https://github.com/seanmcneil/Mixalicious.git", 
    from: "1.0.0")
]
```

### Usage

Mixalicious provides the following functionality:
- Insertion of an audio asset into a video or audio asset
- Extraction of an audio track from a video asset
- Trimming audio or video assets
- Combining audio or video assets
- Scaling the duration of audio or video assets

### Documentation

Mixalicious is built to support Docc for auto generating Apple support documentation. All `public` objects provide rich documentation.

### Support

If you find an issue or can think of an improvement, issues and pull requests are always welcome. 

For pull requests, please be sure to ensure your work is covered with existing or new unit tests.

### Test Data

The included test data is produced by NASA and belongs to the public domain.

## Author

Sean McNeil

## License

Mixalicious is available under the MIT license. See the LICENSE file for more info.
