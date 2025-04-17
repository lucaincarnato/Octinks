//
//  GameObjects.swift
//  ProjectSquid
//
//  Created by Luca Maria Incarnato on 04/02/25.
//

import Foundation
import SwiftUI

// Describes the protagonist, it will be a single-instance class
class Squid {
    var position: CGPoint?
    var ink: Float = 0.0 // Ink level, it will increase over time
    // Squid size, pre-determined
    var width: CGFloat = 150.0
    var height: CGFloat = 75.0
    
    // Check the fullness of the ink
    func canEjectInk() -> Bool {
        if Int(ink) == 1 { return true }
        return false
    }
}

// Describes the dead octopuses
class DeadSquid: Identifiable {
    var id: UUID = UUID()
    var position: CGPoint = CGPoint(x: 10.0, y: 10.0)
    var width: CGFloat = 90.0
    var height: CGFloat = 90.0
    var rotation: Double = 0
    
    // Instance the object with a random position and a random sprite
    init(_ screenWidth: CGFloat, _ screenHeight: CGFloat) {
        position.x = CGFloat(Double.random(in: 1..<screenWidth))
        position.y = CGFloat(Double.random(in: 1..<screenHeight))
        rotation = Double.random(in: 0..<360)
    }
}

// Describes the obstacles the protagonist needs to dodge or cancel
class Waste: Identifiable {
    var id: UUID = UUID() // Needed because it will be an array of wastes
    var name: String = "" // Points a filename for the sprites
    var position: CGPoint = CGPoint(x: 10.0, y: 10.0)
    // Waste size and velocity, pre-determined
    var width: CGFloat = 80.0
    var height: CGFloat = 80.0
    var velocity: Double = 100.0
    var rotation: Double = 0
    
    // Instance the object with a random position and a random sprite
    init(_ screenWidth: CGFloat, _ screenHeight: CGFloat, from names: [String], with velocity: Double) {
        position.x = CGFloat(Double.random(in: 1..<screenWidth))
        position.y = CGFloat(Double.random(in: -screenHeight/2..<(-width)))
        name = names[Int.random(in: 0..<names.count)]
        self.velocity = velocity + Double(Int.random(in: -20..<20))
        rotation = Double.random(in: 0..<360)
    }
    
    init(_ position: CGPoint, from names: [String]){
        self.position = position        
        name = names[Int.random(in: 0..<names.count)]
        velocity = 0
        rotation = Double.random(in: 0..<360)
    }
    
    // Checks if the waste is colliding with the squid
    func isColliding(with squid: Squid) -> Bool {
        // Creates squid's and waste's rectangles from positions and sizes
        let selfCollider: CGRect = CGRect(x: position.x - width/2, y: position.y - height/2, width: width, height: height)
        let squidCollider: CGRect = CGRect(x: (squid.position?.x ?? 0) - squid.width/2, y: (squid.position?.y ?? 0) - squid.height/2, width: squid.width, height: squid.height)
        // Checks collision
        if selfCollider.intersects(squidCollider) { return true }
        return false
    }
    
    // Checks if the stroke is on collider's position
    func isErasing(with stroke: CGRect) -> Bool{
        let selfCollider: CGRect = CGRect(x: position.x - width/2, y: position.y - height/2, width: width, height: height)
        if selfCollider.intersects(stroke) { return true }
        return false
    }
    
    // Changes waste's position according to velocity and delta time
    func move(with delta: Double) {
        position.y += velocity * delta
    }
    
    // Set function for the onboarding (that's why velocity = 0)
    func setWaste(at position: CGPoint, with name: String){
        self.position = position
        self.name = name
        velocity = 0
    }
}
