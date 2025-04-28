//
//  TutorialView.swift
//  Octinks
//
//  Created by Luca Maria Incarnato on 22/04/25.
//

import SwiftUI
import PencilKit

struct TutorialView: View {
    @State var onboardingStatus: Int = 0
    
    // Disables animations when changing view
    init(){
        UINavigationBar.setAnimationsEnabled(false)
    }
    
    var body: some View {
        NavigationStack{
            switch onboardingStatus {
            case 0:
                DisclaimerView(onboardingStatus: $onboardingStatus)
            case 1:
                EnemiesView(onboardingStatus: $onboardingStatus)
            case 2:
                SqueezeView(onboardingStatus: $onboardingStatus)
            case 3:
                MovementView(onboardingStatus: $onboardingStatus)
            case 4:
                ObjectiveView(onboardingStatus: $onboardingStatus)
            default:
                Text("Something went wrong")
            }
        }
    }
}

// Shows only text to let user use iPad on landscape and Apple Pencil Pro
private struct DisclaimerView: View {
    @Binding var onboardingStatus: Int
    
    var body: some View {
        // Game scene
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("seabed")
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                    .position(x: geometry.size.width/2, y: geometry.size.height/2)
                
                // Onboarding's text
                VStack{
                    Image("IconImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    // Custom shape to show outline
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .overlay{
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.accentColor, lineWidth: 1)
                        }
                        .padding()
                    Text("Welcome to Octinks!")
                        .font(.system(size: 50))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.accentColor)
                        .bold()
                    Text("Enjoy on iPad in landscape mode\nand with Apple Pencil Pro")
                        .font(.system(size: 30))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.black.opacity(0.3))
                        .bold()
                }
                .position(x: geometry.size.width/2, y: geometry.size.height * 0.35)
                Button() {
                    onboardingStatus += 1
                    if onboardingStatus > 4 { onboardingStatus = 0 }
                } label: {
                    Text("Start")
                        .bold()
                        .padding(.horizontal)
                        .font(.system(size: 50))
                }
                .buttonStyle(.bordered)
                .position(x: geometry.size.width/2, y: geometry.size.height * 0.6)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        // Disables hierarchical navigation, in favor of content driven navigation
        .navigationBarBackButtonHidden(true)
        .frame(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
    }
}

// Shows how to delete objects
private struct EnemiesView: View {
    @Binding var onboardingStatus: Int
    @State var canMove: Bool = false
    
    // Internal clock
    @State var seconds: Int = 0
    let durationTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Timer to update the scene at 60 FPS
    @State var frames = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    // Characters
    @State var squid: Squid = Squid()
    @State var wastes: [Waste] = [] // MARK: UNDERSTAND WHY THE MOVEMENT WITH HOVER HAPPENS ONLY IF THERE ARE WASTES INSTANCED
    
    @State var hoverTick: Int = 0 // Describes how many frames ticks the squid's movement
    
    // Sprite names to point at images
    let sprites: [String] = ["can", "bottle", "plastic"]
    
    // Constants for difficulty balance
    let SPAWN_RATE: Int = 4
    let INK_RATE: Int = 2
    let INK_QUANTITY: Float = 0.1
    
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
                // Onboarding's text
                VStack {
                    Text("Draw over litter\nto delete it")
                        .font(.system(size: 50))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.accentColor)
                        .bold()
                    Text("(it consumes some ink)")
                        .font(.system(size: 30))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.black.opacity(0.3))
                        .bold()
                }
                .position(x: geometry.size.width/2, y: geometry.size.height * 0.4)
                // Protagonist rendering
                Image("squid")
                    .resizable()
                    .scaledToFill()
                    .frame(width: squid.width, height: squid.height)
                    .position(x: squid.position?.x ?? geometry.size.width/2, y: squid.position?.y ?? geometry.size.height - 1.5*squid.height)
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
                HoverView(squid: $squid, hoverPosition: $hoverPosition, strokeRect: $strokeRect, canvasView: $canvasView, inkEjection: {})
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if canMove {
                    Button() {
                        onboardingStatus += 1
                        if onboardingStatus > 4 { onboardingStatus = 0 }
                    } label: {
                        Text("Next")
                            .bold()
                            .padding(.horizontal)
                            .font(.system(size: 50))
                    }
                    .buttonStyle(.bordered)
                    .position(x: geometry.size.width/2, y: geometry.size.height * 0.6)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            // Creates an internal clock from which all time sensitive operations will be synched
            .onReceive(durationTimer) { _ in
                seconds += 1
                // Spawn a fixed number of obstacle every fixed number of seconds
                if seconds % SPAWN_RATE == 0 {
                    wastes = [Waste(CGPoint(x: geometry.size.width/2, y: geometry.size.height/5), from: sprites)]
                }
                // Increments by a fixed number the ink every fixed number of seconds
                if seconds % INK_RATE == 0 {
                    if squid.ink >= 0.0 && squid.ink < 1.0 { squid.ink += INK_QUANTITY }
                    else if squid.ink >= 1.0 { squid.ink = 1.0 }
                    else if squid.ink < 0.0 { squid.ink = 0.0 }
                }
            }
            .onReceive(frames) { _ in
                updateWaste()
                // Reset the possibility to delete obstacles with pencil
                strokeRect = nil
                // Transfers only vertical position from the hover to the squid
                let bufferX = squid.position?.x ?? geometry.size.height/2 // Allows the squid to remain in position once pencil leaves the screen
                squid.position?.x = hoverPosition?.x ?? bufferX
                // Changes the tick counter
                hoverTick += 1
                if hoverTick > 60 { hoverTick = 0 }
            }
            .onAppear {
                squid.position = CGPoint(x: geometry.size.width/2, y: geometry.size.height - 1.5*squid.height) // Starting position
                wastes = [Waste(CGPoint(x: geometry.size.width/2, y: geometry.size.height/5), from: sprites)]
                
            }
        }
        // Disables hierarchical navigation, in favor of content driven navigation
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            frames.upstream.connect().cancel()
            durationTimer.upstream.connect().cancel()
        }
        .frame(width:  UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
    }
    
    // Movement system for the obstacles
    func updateWaste(){
        // Goes through obstacles' array and update each single position
        wastes = wastes.compactMap { waste in
            let newWaste = waste
            // Checks if stroke is on waste and, if yes, deletes it
            if newWaste.isErasing(with: strokeRect ?? CGRect(origin: CGPoint(x: -1000, y: -1000), size: CGSize(width: 2, height: 2))) {
                DispatchQueue.main.async{
                    wastes.removeAll(where: { $0.id == newWaste.id })
                    canMove = true
                    return
                }
            }
            return newWaste
        }
    }
}

// Shows the squeeze ultimate
private struct SqueezeView: View {
    @Binding var onboardingStatus: Int
    @State var canMove: Bool = false
    
    // Internal clock
    @State var seconds: Int = 0
    let durationTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Timer to update the scene at 60 FPS
    @State var frames = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    // Characters
    @State var squid: Squid = Squid()
    @State var wastes: [Waste] = [] // MARK: UNDERSTAND WHY THE MOVEMENT WITH HOVER HAPPENS ONLY IF THERE ARE WASTES INSTANCED
    
    @State var hoverTick: Int = 0 // Describes how many frames ticks the squid's movement
    
    // Sprite names to point at images
    let sprites: [String] = ["can", "bottle", "plastic"]
    
    // Constants for difficulty balance
    let SPAWN_RATE: Int = 4
    let INK_RATE: Int = 2
    let INK_QUANTITY: Float = 0.1
    
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
                // Onboarding's text
                VStack {
                    Text("Squeeze the Apple Pencil Pro\nor tap with three fingers\nwhen ink is full to delete all the litter")
                        .font(.system(size: 50))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.accentColor)
                        .bold()
                    Text("(consumes all the ink)")
                        .font(.system(size: 30))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.black.opacity(0.3))
                        .bold()
                }
                .position(x: geometry.size.width/2, y: geometry.size.height * 0.4)
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
                                    canMove = true
                                    wastes = []
                                    squid.ink = 0.5
                                }
                            }
                        }
                    }
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
                HoverView(squid: $squid, hoverPosition: $hoverPosition, strokeRect: $strokeRect, canvasView: $canvasView, inkEjection: {
                    // Used to eject ink with fingers
                    if squid.canEjectInk() {
                        // Executing on the main thread, it forces a refresh and deletes also the sprites
                        DispatchQueue.main.async {
                            canMove = true
                            wastes = []
                            squid.ink = 0.5
                        }
                    }
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                if canMove{
                    Button() {
                        onboardingStatus += 1
                        if onboardingStatus > 4 { onboardingStatus = 0 }
                    } label: {
                        Text("Next")
                            .bold()
                            .padding(.horizontal)
                            .font(.system(size: 50))
                    }
                    .buttonStyle(.bordered)
                    .position(x: geometry.size.width/2, y: geometry.size.height * 0.6)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            // Creates an internal clock from which all time sensitive operations will be synched
            .onReceive(durationTimer) { _ in
                seconds += 1
                // Spawn a fixed number of obstacle every fixed number of seconds
                if seconds % SPAWN_RATE == 0 {
                    wastes = [
                        Waste(CGPoint(x: geometry.size.width/3, y: geometry.size.height/5), from: sprites),
                        Waste(CGPoint(x: geometry.size.width/2, y: geometry.size.height/5), from: sprites),
                        Waste(CGPoint(x: geometry.size.width * 2/3 , y: geometry.size.height/5), from: sprites)
                    ]
                }
                // Increments by a fixed number the ink every fixed number of seconds
                if seconds % INK_RATE == 0 {
                    if squid.ink >= 0.0 && squid.ink < 1.0 { squid.ink += INK_QUANTITY }
                    else if squid.ink >= 1.0 { squid.ink = 1.0 }
                    else if squid.ink < 0.0 { squid.ink = 0.0 }
                }
            }
            .onReceive(frames) { _ in
                updateWaste()
                // Reset the possibility to delete obstacles with pencil
                strokeRect = nil
                // Transfers only vertical position from the hover to the squid
                let bufferX = squid.position?.x ?? geometry.size.height/2 // Allows the squid to remain in position once pencil leaves the screen
                squid.position?.x = hoverPosition?.x ?? bufferX
                // Changes the tick counter
                hoverTick += 1
                if hoverTick > 60 { hoverTick = 0 }
            }
            .onAppear {
                squid.position = CGPoint(x: geometry.size.width/2, y: geometry.size.height - 1.5*squid.height) // Starting position
                squid.ink = 0.9
                wastes = [
                    Waste(CGPoint(x: geometry.size.width/3, y: geometry.size.height/5), from: sprites),
                    Waste(CGPoint(x: geometry.size.width/2, y: geometry.size.height/5), from: sprites),
                    Waste(CGPoint(x: geometry.size.width * 2/3 , y: geometry.size.height/5), from: sprites)
                ]
            }
        }
        // Disables hierarchical navigation, in favor of content driven navigation
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            frames.upstream.connect().cancel()
            durationTimer.upstream.connect().cancel()
        }
        .frame(width:  UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
    }
    
    // Movement system for the obstacles
    func updateWaste(){
        // Goes through obstacles' array and update each single position
        wastes = wastes.compactMap { waste in
            let newWaste = waste
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
}

// Shows only the movement tutorial
private struct MovementView: View {
    @Binding var onboardingStatus: Int
    @State var canMove: Bool = false
    
    // Timer to update the scene at 60 FPS
    @State var frames = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    // Characters
    @State var squid: Squid = Squid()
    @State var hoverTick: Int = 0 // Describes how many frames ticks the squid's movement
    
    // Delta time for 60 fps
    let DELTA_TIME = 0.016
    
    // Buffers
    @State private var hoverPosition: CGPoint? = nil // Position to detect hover and pass it to the squid
    @State private var strokeRect: CGRect? = nil // Rectangle to detect stroke position and dimensions
    @State private var canvasView = PKCanvasView() // Canvas to let user draw
    
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
                // Onboarding's text
                VStack{
                    Text("Hover the Apple Pencil\nor drag with two fingers to move")
                        .font(.system(size: 50))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.accentColor)
                        .bold()
                    Text("(don't touch the screen with the Apple Pencil Pro)")
                        .font(.system(size: 30))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.black.opacity(0.3))
                        .bold()
                }
                .position(x: geometry.size.width/2, y: geometry.size.height * 0.4)
                // Protagonist rendering
                Image("squid")
                    .resizable()
                    .scaledToFill()
                    .frame(width: squid.width, height: squid.height)
                    .position(x: squid.position?.x ?? geometry.size.width/2, y: squid.position?.y ?? geometry.size.height - squid.height)
                    .id(hoverTick) // Associate an unique id for every frame to ignite changes
                // Apple Pencil hover detection and drawing system
                HoverView(squid: $squid, hoverPosition: $hoverPosition, strokeRect: $strokeRect, canvasView: $canvasView, inkEjection: {})
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if canMove {
                    Button() {
                        onboardingStatus += 1
                        if onboardingStatus > 4 { onboardingStatus = 0 }
                    } label: {
                        Text("Next")
                            .bold()
                            .padding(.horizontal)
                            .font(.system(size: 50))
                    }
                    .buttonStyle(.bordered)
                    .position(x: geometry.size.width/2, y: geometry.size.height * 0.6)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            // Creates an internal clock from which all time sensitive operations will be synched
            .onReceive(frames) { _ in
                strokeRect = nil
                // Transfers only vertical position from the hover to the squid
                let bufferX = squid.position?.x ?? geometry.size.height/2 // Allows the squid to remain in position once pencil leaves the screen
                squid.position?.x = hoverPosition?.x ?? bufferX
                // Changes the tick counter
                hoverTick += 1
                if hoverTick > 60 { hoverTick = 0 }
            }
            .onAppear {
                // If the dimension is determined before something being rendered, it is 0.0, 0.0
                DispatchQueue.main.async{
                    squid.position = CGPoint(x: geometry.size.width/2, y: geometry.size.height - 1.5*squid.height) // Starting position
                }
            }
            .onChange(of: hoverPosition) {
                canMove = true
            }
        }
        // Disables hierarchical navigation, in favor of content driven navigation
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            frames.upstream.connect().cancel()
        }
        .frame(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
    }
}

// Sets up a goal
private struct ObjectiveView: View {
    @Binding var onboardingStatus: Int
    
    var body: some View {
        // Game scene
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("seabed")
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                // Onboarding's text
                Text("Avoid litter and survive")
                    .font(.system(size: 50))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.accentColor)
                    .bold()
                    .position(x: geometry.size.width/2, y: geometry.size.height * 0.4)
                NavigationLink() {
                    GameSceneView()
                } label: {
                    Text("Start")
                        .bold()
                        .padding(.horizontal)
                        .font(.system(size: 50))
                }
                .buttonStyle(.bordered)
                .position(x: geometry.size.width/2, y: geometry.size.height * 0.6)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        // Disables hierarchical navigation, in favor of content driven navigation
        .navigationBarBackButtonHidden(true)
        .frame(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
    }
}
