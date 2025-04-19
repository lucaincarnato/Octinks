//
//  MyApp.swift
//  ProjectSquid
//
//  Created by Luca Maria Incarnato on 04/02/25.
//

import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                GameSceneView()
                    .preferredColorScheme(.light)
            }
        }
    }
}
