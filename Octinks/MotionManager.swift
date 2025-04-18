//
//  MotionManager.swift
//  Octinks
//
//  Created by Luca Maria Incarnato on 18/04/25.
//

import SwiftUI
import CoreMotion

class MotionManager: ObservableObject {
    @Published var roll: Double = 0.0
    private let motionManager = CMMotionManager()

    init() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            DispatchQueue.main.async {
                self.roll = data.attitude.pitch
            }
        }
    }
}
