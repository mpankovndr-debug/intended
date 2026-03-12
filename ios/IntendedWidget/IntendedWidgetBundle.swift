//
//  IntendedWidgetBundle.swift
//  IntendedWidget
//
//  Created by Maksim Pankov on 10/03/2026.
//

import WidgetKit
import SwiftUI

@main
struct IntendedWidgetBundle: WidgetBundle {
    var body: some Widget {
        IntendedBasicWidget()
        IntendedPremiumWidget()
        if #available(iOS 16.0, *) {
            IntendedLockScreenWidget()
        }
    }
}
