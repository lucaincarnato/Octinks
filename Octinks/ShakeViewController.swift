//
//  ShakeViewController.swift
//  Octinks
//
//  Created by Luca Maria Incarnato on 18/04/25.
//

import UIKit
import SwiftUI

// 1) Il view controller che intercetta lo shake
class ShakeViewController: UIViewController {
    /// Closure richiamata al termine del movimento shake
    var onShake: (() -> Void)?

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        guard motion == .motionShake else { return }
        onShake?()
    }
}

// 2) UIViewControllerRepresentable per usarlo in SwiftUI
struct ShakeDetector: UIViewControllerRepresentable {
    /// Azione da eseguire quando viene rilevato lo shake
    let onShake: () -> Void

    func makeUIViewController(context: Context) -> ShakeViewController {
        let vc = ShakeViewController()
        vc.onShake = onShake
        return vc
    }

    func updateUIViewController(_ uiViewController: ShakeViewController, context: Context) {
        // non serve aggiornare nulla
    }
}
