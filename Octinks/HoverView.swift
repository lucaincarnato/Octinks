//
//  HoverView.swift
//  ProjectSquid
//
//  Created by Luca Maria Incarnato on 04/02/25.
//

import SwiftUI
import PencilKit
import UIKit

// SwiftUI view configured as UIKit view to manage the Apple Pencil main interactions (drawing and hovering)
struct HoverView: UIViewRepresentable {
    @Binding var squid: Squid // Protagonist reference
    @Binding var hoverPosition: CGPoint? // Hover position
    @Binding var strokeRect: CGRect? // Stroke collider
    @Binding var canvasView: PKCanvasView // Drawing's canvas
    
    // Method responsible for the connection between UIKit and SwiftUI
    func makeUIView(context: Context) -> PKCanvasView {
        // Canvas configuration
        canvasView.drawingPolicy = .anyInput // Allow only Apple Pencil touches for drawing
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.alwaysBounceVertical = false
        canvasView.delegate = context.coordinator // Delegate to cordinator
        // Hover recognition
        if #available(iOS 16.0, *) {
            let hoverGestureRecognizer = UIHoverGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleHover(_:)))
            canvasView.addGestureRecognizer(hoverGestureRecognizer)
            // Add recognizer for two finger touch
            let twoFingerPanRecognizer = UIPanGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.handleTwoFingerPan(_:)))
            twoFingerPanRecognizer.minimumNumberOfTouches = 2
            twoFingerPanRecognizer.maximumNumberOfTouches = 2
            canvasView.addGestureRecognizer(twoFingerPanRecognizer)
        }
        // Returns what the SwiftUI view will show
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
    
    // Instance cordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(squid: $squid, hoverPosition: $hoverPosition, strokeRect: $strokeRect, canvasView: $canvasView)
    }
}

// Separates UI view and navigation, managing navigation's logic
class Coordinator: NSObject, PKCanvasViewDelegate {
    @Binding var squid: Squid // Protagonist reference
    @Binding var hoverPosition: CGPoint? // Hover position
    @Binding var strokeRect: CGRect? // Stroke collider
    @Binding var canvasView: PKCanvasView // Drawing's canvas
    
    var inkAvailable: Bool = true // The possibility of using the ink related to squid's properties
    private var strokeTimers: [Int: Timer] = [:] // Vector of timers related to all the strokes drawn on the screen
    
    // Constants for difficulty balance
    private var ERASING_TIME: TimeInterval = 0.2
    private var INK_QUANTITY: Float = 0.1
    
    // Initializer with custom values
    init(squid: Binding<Squid>, hoverPosition: Binding<CGPoint?>, strokeRect: Binding<CGRect?>, canvasView: Binding<PKCanvasView>) {
        self._squid = squid
        self._hoverPosition = hoverPosition
        self._strokeRect = strokeRect
        self._canvasView = canvasView
    }

    // Handler for two finger panning
    @objc func handleTwoFingerPan(_ recognizer: UIPanGestureRecognizer) {
        // Drawing managment system here because before drawing the user needs to pan, so the condition are checked before drawing
        // Allow ink strokes if the player has enaugh ink for at least one stroke
        if squid.ink >= 0.1 {
            inkAvailable = true
        }
        // Enables or disables the drawing ability according to the ink availability
        if inkAvailable {
            canvasView.drawingGestureRecognizer.isEnabled = true
        } else {
            canvasView.drawingGestureRecognizer.isEnabled = false
        }
        // Set hoverPosition in the main thread (thus the self) according to how the user is acting with the two finger pan
        let location = recognizer.location(in: recognizer.view)
        switch recognizer.state {
        case .began, .changed:
            DispatchQueue.main.async {
                self.hoverPosition = location
            }
        case .ended, .cancelled, .failed:
            DispatchQueue.main.async {
                self.hoverPosition = nil
            }
        default:
            DispatchQueue.main.async {
                self.hoverPosition = nil
            }
            break
        }
    }
    
    // Manage the Apple Pencil's hover
    @objc func handleHover(_ recognizer: UIHoverGestureRecognizer) {
        // Drawing managment system here because before drawing the user needs to hover, so the condition are checked before drawing
        // Allow ink strokes if the player has enaugh ink for at least one stroke
        if squid.ink >= 0.1 {
            inkAvailable = true
        }
        // Enables or disables the drawing ability according to the ink availability
        if inkAvailable {
            canvasView.drawingGestureRecognizer.isEnabled = true
        } else {
            canvasView.drawingGestureRecognizer.isEnabled = false
        }
        // Set hoverPosition in the main thread (thus the self) according to how the user is acting with the Apple Pencil's hover
        let location = recognizer.location(in: recognizer.view)
        switch recognizer.state {
        case .began, .changed:
            DispatchQueue.main.async {
                self.hoverPosition = location
            }
        case .ended, .cancelled, .failed:
            DispatchQueue.main.async {
                self.hoverPosition = nil
            }
        default:
            DispatchQueue.main.async {
                self.hoverPosition = nil
            }
            break
        }
    }
    
    // Called everytime the canvas' drawing changes to clear the screen after a fixed amount of time
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        // Because any change means that the player drew with the Apple Pencil, the ink needs to be decreased
        squid.ink -= INK_QUANTITY
        // After changing ink level, the availability is checked again
        if squid.ink < 0.1 {
            inkAvailable = false
            squid.ink = 0.0
        }
        // Set up a vector of all the strokes on the canvas
        let newStrokes = canvasView.drawing.strokes
        // Identifies strokes not already set to die
        for (index, stroke) in newStrokes.enumerated() {
            // Communicate stroke's collider with the outside to eventually delete wastes
            strokeRect = stroke.renderBounds
            // Checks if the stroke has already been timered
            if strokeTimers[index] == nil {
                // Set up a timer to delete the stroke after a fixed amount of time
                let timer = Timer.scheduledTimer(withTimeInterval: ERASING_TIME, repeats: false) { [weak self] _ in
                    self?.removeStroke(at: index)
                }
                // Now the stroke has been timered
                strokeTimers[index] = timer
            }
        }
        // Clears timers for already expired strokes
        let validIndices = Set(0..<newStrokes.count)
        let removedIndices = Set(strokeTimers.keys).subtracting(validIndices)
        for index in removedIndices {
            strokeTimers[index]?.invalidate()
            strokeTimers.removeValue(forKey: index)
        }
    }
    
    // Remove a specific stroke
    private func removeStroke(at index: Int) {
        // Checks if the index is valid
        guard index < canvasView.drawing.strokes.count else { return }
        // Updates canvas' drawings
        var drawing = canvasView.drawing
        drawing.strokes.remove(at: index)
        canvasView.drawing = drawing
        // Invalidate and remove the related timer
        strokeTimers[index]?.invalidate()
        strokeTimers.removeValue(forKey: index)
    }
}
