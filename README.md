# VideoEditorKit

A Video Editor allowing the following types of edit:

- Speed Rate
- Trim

## How to use

### Display the video editor

```swift
let videoEditorViewController = VideoEditorViewFactory().makeVideoEditorViewController()
videoEditorViewController.delegate = self
let url = Bundle.main.url(forResource: "Video1", withExtension: "mp4")!
let asset = AVAsset(url: url)

videoEditorViewController.load(asset: asset)
```

### Get edited asset

Implement the VideoEditorViewControllerDelegate protocol

```swift
func save(editedAsset: AVAsset) {

}
```

## TODO

- Fix Cropping
- Reintroduce video composition
- Regenerate timeline after trimming
