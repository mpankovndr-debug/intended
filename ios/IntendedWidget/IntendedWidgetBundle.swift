import WidgetKit
import SwiftUI

@main
struct IntendedWidgetBundle: WidgetBundle {
    var body: some Widget {
        IntendedBasicWidget()
        IntendedPremiumWidget()
        IntendedLockScreenWidget()
        IntendedPauseWidget()
    }
}
