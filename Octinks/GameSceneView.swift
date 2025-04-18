//
//  ContentView.swift
//  ProjectSquid
//
//  Created by Luca Maria Incarnato on 04/02/25.
//

import SwiftUI
import PencilKit
import Foundation

struct GameSceneView: View {
    // Game state variable
    @State var gameOver: Bool = false
    @State var deadOctopuses: Int = 0
    
    // Internal clock
    @State var seconds: Int = 0
    let durationTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Timer to update the scene at 60 FPS
    @State var frames = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    // Characters
    @State var squid: Squid = Squid()
    @State var wastes: [Waste] = [] // MARK: UNDERSTAND WHY THE MOVEMENT WITH HOVER HAPPENS ONLY IF THERE ARE WASTES INSTANCED
    @State var dead: [DeadSquid] = []
    
    @State var hoverTick: Int = 0 // Describes how many frames ticks the squid's movement 
    
    // Sprite names to point at images
    let sprites: [String] = ["can", "bottle", "plastic"]
    
    // Constants for difficulty balance
    let SPAWN_RATE: Int = 3
    @State var SPAWN_QUANTITY: Int = 7
    let INK_RATE: Int = 2
    let INK_QUANTITY: Float = 0.2
    @State var INITIAL_VELOCITY: Double = 100
    
    // Delta time for 60 fps
    let DELTA_TIME = 0.016
    
    // Buffers
    @State private var hoverPosition: CGPoint? = nil // Position to detect hover and pass it to the squid
    @State private var strokeRect: CGRect? = nil // Rectangle to detect stroke position and dimensions
    @State private var canvasView = PKCanvasView() // Canvas to let user draw
    @State private var isPulsing: Bool = false // Boolean value for score animation
    
    var body: some View {
        // Game scene
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("seabed")
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                // Progress bars to show ink level
                InkBar(progress: squid.ink)
                    .frame(height: geometry.size.height * 0.75)
                    .position(x: geometry.size.width * 0.05, y: geometry.size.height / 2)
                InkBar(progress: squid.ink)
                    .frame(height: geometry.size.height * 0.75)
                    .position(x: geometry.size.width * 0.95, y: geometry.size.height / 2)
                // Dead squids sprites, not gameObjects
                ForEach(dead) { deadSquid in
                    Image("deadSquid")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.6)
                        .rotationEffect(Angle(degrees: deadSquid.rotation))
                        .frame(width: deadSquid.width, height: deadSquid.height)
                        .position(deadSquid.position)
                }
                // Seconds counter
                VStack{
                    // Counter's text
                    Text("It's a matter of time")
                        .font(.system(size: 50))
                        .foregroundColor(isPulsing ? Color.pink : Color.black.opacity(0.3)) // Changes the color every tick
                        .animation(.easeInOut(duration: 0.2), value: isPulsing) // Pulse the text every tick
                        .bold()
                    // Counter for user's purpose
                    HStack {
                        Text("\(deadOctopuses)")
                            .font(.system(size: 400))
                            .foregroundColor(isPulsing ? Color.pink : Color.black.opacity(0.3)) // Changes the color every tick
                            .animation(.easeInOut(duration: 0.2), value: isPulsing) // Pulse the text every tick
                        Text("s")
                            .font(.system(size: 100))
                            .foregroundColor(isPulsing ? Color.pink : Color.black.opacity(0.3)) // Changes the color every tick
                            .animation(.easeInOut(duration: 0.2), value: isPulsing) // Pulse the text every tick
                    }
                }
                .position(x: geometry.size.width/2, y: geometry.size.height/2)
                // Protagonist rendering
                Image("squid")
                    .resizable()
                    .scaledToFill()
                    .frame(width: squid.width, height: squid.height)
                    .position(x: squid.position?.x ?? geometry.size.width/2, y: squid.position?.y ?? geometry.size.height - 1.5*squid.height)
                    .onPencilSqueeze { phase in
                        if case .ended(_) = phase {
                            if squid.canEjectInk() {
                                // Executing on the main thread, it forces a refresh and deletes also the sprites
                                DispatchQueue.main.async {
                                    squid.ink = 0
                                    wastes = []
                                }
                            }
                        }
                    }
                    .background(
                        ShakeDetector {
                            if squid.canEjectInk() {
                                // Executing on the main thread, it forces a refresh and deletes also the sprites
                                DispatchQueue.main.async {
                                    squid.ink = 0
                                    wastes = []
                                }
                            }
                        }
                        .frame(width: 0, height: 0)
                    )
                    .id(hoverTick) // Associate an unique id for every frame to ignite changes
                // Rendering of all obstacles
                ForEach(wastes) { waste in
                    Image(waste.name)
                        .resizable()
                        .scaledToFill()
                        .rotationEffect(Angle(degrees: waste.rotation))
                        .frame(width: waste.width, height: waste.height)
                        .position(waste.position)
                }
                // Apple Pencil hover detection and drawing system
                HoverView(squid: $squid, hoverPosition: $hoverPosition, strokeRect: $strokeRect, canvasView: $canvasView)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            // Shows death screen once the user dies
            .fullScreenCover(isPresented: $gameOver) {
                DeathScreenView(deadOctopuses: $deadOctopuses)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            // Creates an internal clock from which all time sensitive operations will be synched
            .onReceive(durationTimer) { _ in
                seconds += 1
                // Spawn a fixed number of obstacle every fixed number of seconds
                if seconds % SPAWN_RATE == 0 {
                    for _ in 0..<SPAWN_QUANTITY {
                        wastes.append(Waste(geometry.size.width, geometry.size.height, from: sprites, with: INITIAL_VELOCITY))
                    }
                    INITIAL_VELOCITY += 5.0 // Increases velocity every spawn
                }
                // Spawn a fixed number of dead squid every fixed number of seconds
                if seconds % SPAWN_RATE - 1 == 0 {
                    for _ in 0..<2 {
                        dead.append(DeadSquid(geometry.size.width, geometry.size.height))
                    }
                }
                // Increments by a fixed number the ink every fixed number of seconds
                if seconds % INK_RATE == 0 {
                    if squid.ink >= 0.0 && squid.ink < 1.0 { squid.ink += INK_QUANTITY }
                    else if squid.ink >= 1.0 { squid.ink = 1.0 }
                    else if squid.ink < 0.0 { squid.ink = 0.0 }
                }
                // An octopus dies every seconds (fake stat)
                if seconds % 1 == 0 {
                    deadOctopuses += 1
                    // Changes pulse's state
                    withAnimation {
                        isPulsing = true
                    }
                    // Goes back to original once animation has ended
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            isPulsing = false
                        }
                    }
                }
                // Spawns an obstacle more each minute
                if seconds % 60 == 0 {
                    SPAWN_QUANTITY += 1
                }
            }
            .onReceive(frames) { _ in
                // At each frame tick, the wastes move and the collision is checked
                updateMovement(geometry.size.height)
                // Reset the possibility to delete obstacles with pencil
                strokeRect = nil
                // The excessive squids are removed
                removeExcesses()
                // Transfers only vertical position from the hover to the squid
                let bufferX = squid.position?.x ?? geometry.size.width/2 // Allows the squid to remain in position once pencil leaves the screen
                squid.position?.x = hoverPosition?.x ?? bufferX   
                // Changes the tick counter
                hoverTick += 1
                if hoverTick > 60 { hoverTick = 0 }
            }
            .onAppear {
                squid.position = CGPoint(x: geometry.size.width/2, y: geometry.size.height - 1.5*squid.height) // Starting position
            }
        }
        // Disables hierarchical navigation, in favor of content driven navigation
        .navigationBarBackButtonHidden(true)
        .frame(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
    }
    
    // Movement system for the obstacles
    func updateMovement(_ screenHeight: Double){
        // Checks if there are wastes outside of the screen that need to be deleted
        for waste in wastes {
            if waste.position.y > screenHeight + waste.width { wastes.removeAll(where: { $0.id == waste.id}) }
        }
        // Goes through obstacles' array and update each single position
        wastes = wastes.compactMap { waste in
            let newWaste = waste
            newWaste.move(with: DELTA_TIME)
            // Checks game over after each step
            if newWaste.isColliding(with: squid) {
                gameOver = true
                // Executing on the main thread, it forces a refresh and deletes all the gameObjects
                DispatchQueue.main.async {
                    wastes = []
                    dead = []
                }
                frames.upstream.connect().cancel()
                durationTimer.upstream.connect().cancel()
            }
            // Checks if stroke is on waste and, if yes, deletes it
            if newWaste.isErasing(with: strokeRect ?? CGRect(origin: CGPoint(x: -1000, y: -1000), size: CGSize(width: 2, height: 2))) {
                DispatchQueue.main.async{
                    wastes.removeAll(where: { $0.id == newWaste.id })
                    return
                }
            }
            return newWaste
        }
    }
    // When there's too many dead squids, remove the first spawned
    func removeExcesses(){
        // Remove squids only if there are more than 50
        if dead.count >= 50 {
            // Let the array be always of 50 items
            while dead.count > 50 {
                dead.removeFirst()
            }
        }
    }
}
