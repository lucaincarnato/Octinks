//
//  TutorialView.swift
//  Octinks
//
//  Created by Luca Maria Incarnato on 22/04/25.
//

import SwiftUI
import PencilKit
import Combine // Only to pass the timer as parameter

struct TutorialView: View {
    @State var progress: Int = 0
    @State var frames = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    @State private var strokeRect: CGRect? = nil // Rectangle to detect stroke position and dimensions
    @State private var canvasView = PKCanvasView() // Canvas to let user draw
    
    // Characters
    @State var squid: Squid = Squid()
    @State var wastes: [Waste] = []
    let sprites: [String] = ["can", "bottle", "plastic"]
    
    // Constants for difficulty balance
    let SPAWN_RATE: Int = 3
    let INK_RATE: Int = 2
    let INK_QUANTITY: Float = 0.2

    
    var body: some View {
        switch progress {
        case 0:
            DrawView(progress: $progress, frames: $frames, strokeRecct: $strokeRect, canvasView: $canvasView, squid: $squid, wastes: $wastes, sprites: sprites, SPAWN_RATE: SPAWN_RATE, INK_RATE: INK_RATE, INK_QUANTITY: INK_QUANTITY)
        case 1:
            SqueezeView(progress: $progress, frames: $frames, strokeRecct: $strokeRect, canvasView: $canvasView, squid: $squid, wastes: $wastes, sprites: sprites, SPAWN_RATE: SPAWN_RATE, INK_RATE: INK_RATE, INK_QUANTITY: INK_QUANTITY)
        case 2:
            MovementView(progress: $progress, frames: $frames, strokeRecct: $strokeRect, canvasView: $canvasView, squid: $squid, wastes: $wastes)
        case 3:
            MissionView()
        default:
            Text("Something went wrong")
        }
    }
}

struct DrawView: View {
    @Binding var progress: Int
    @Binding var frames: Publishers.Autoconnect<Timer.TimerPublisher>
    
    @Binding var strokeRecct: CGRect? // Rectangle to detect stroke position and dimensions
    @Binding var canvasView: PKCanvasView // Canvas to let user draw
    
    @Binding var squid: Squid
    @Binding var wastes: [Waste]
    let sprites: [String]
    
    // Constants for difficulty balance
    let SPAWN_RATE: Int
    let INK_RATE: Int
    let INK_QUANTITY: Float


    var body: some View {
        Text("Hello, World!")
    }
}

struct SqueezeView: View {
    @Binding var progress: Int
    @Binding var frames: Publishers.Autoconnect<Timer.TimerPublisher>
    
    @Binding var strokeRecct: CGRect? // Rectangle to detect stroke position and dimensions
    @Binding var canvasView: PKCanvasView // Canvas to let user draw
    
    @Binding var squid: Squid
    @Binding var wastes: [Waste]
    let sprites: [String]
    
    // Constants for difficulty balance
    let SPAWN_RATE: Int
    let INK_RATE: Int
    let INK_QUANTITY: Float

    var body: some View {
        Text("Hello, World!")
    }
}

struct MovementView: View {
    @Binding var progress: Int
    @Binding var frames: Publishers.Autoconnect<Timer.TimerPublisher>
    
    @Binding var strokeRecct: CGRect? // Rectangle to detect stroke position and dimensions
    @Binding var canvasView: PKCanvasView // Canvas to let user draw
    
    @Binding var squid: Squid
    @Binding var wastes: [Waste]
    
    @State var hoverTick: Int = 0 // Describes how many frames ticks the squid's movement
    @State private var hoverPosition: CGPoint? = nil // Position to detect hover and pass it to the squid
    
    var body: some View {
        Text("Hello, world!")
    }
}

struct MissionView: View {
    var body: some View {
        Text("Hello, world!")
    }
}

#Preview {
    TutorialView()
}
