import SwiftUI
import UIKit

/**
 外部ディスプレイに投影した際に黒い枠ができることがあるのでそれを消すための ViewController
 画面表示時に `view.window?.screen.overscanCompensation = .none` を設定する
 */
@available(iOS, deprecated: 27.0, message: "iOS 27.0 以降は sceneAccessory を利用する")
final class ExternalDisplayViewController<Content> : UIHostingController<Content> where Content : View {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.window?.screen.overscanCompensation = .none
    }
}
