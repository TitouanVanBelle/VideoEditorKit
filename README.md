# VideoEditorKit

A video editor kit allowing the following types of edit:

<br/>
<p align="center">
  <img src="https://i.postimg.cc/8zyjzGLn/Video-Editor-Kit.png" width="400" height="542">
</p>
<br/>

## Features

- Adjust speed rate
- Crop using presets
- Trim begining and end

## How to use

### Display the video editor

```swift
let asset = Bundle.main.url(forResource: "HongKong", withExtension: "mp4")
    .map(AVAsset.init)!
let outputUrl = ...

let controller = VideoEditorViewController(asset: asset, outputUrl: outputUrl)

let navigationController = UINavigationController(rootViewController: controller)
navigationController.modalPresentationStyle = .fullScreen
navigationController.navigationBar.barTintColor = .white
navigationController.navigationBar.shadowImage = UIImage()

present(navigationController, animated: true)
```

### Get notified on edition complete


```swift
controller.onEditCompleted
    .sink { [weak self] _ in
        let item = AVPlayerItem(url: outputUrl)
        self?.editedVideoPlayer.player?.replaceCurrentItem(with: item)
    }
```

## Cropping Presets

| Preset      | Width / Height |
| vertical| 3/4|
| standard | 4/3 |
| portrait | 9/16 |
| square | 1/1 |
| landscape | 16/9 |
| instagram | 4/5 |

## TODO

- Add Audio (mute) video control
- Trim: Prevent trimming handle from going passed each other
- Make dismiss button in Video Control bigger and higher
- Dark Theme
