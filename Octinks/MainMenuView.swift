//
//  MainMenuView.swift
//  Octinks
//
//  Created by Luca Maria Incarnato on 28/04/25.
//

import SwiftUI

struct MainMenuView: View {
    @AppStorage("firstLaunch") var firstLaunch: Bool = true
    
    var body: some View {
        NavigationStack {
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
                    VStack {
                        // Protagonist rendering
                        Image("squid")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 100)
                            .padding(.top, 40)
                        Text("Octinks")
                            .font(.system(size: 150))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.accentColor)
                            .bold()
                        Text("Save Octi from pollution, now!")
                            .font(.system(size: 30))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.black.opacity(0.3))
                            .bold()
                            .padding(.bottom, 100)
                        if firstLaunch {
                            NavigationLink() {
                                TutorialView()
                            } label: {
                                Text("Start")
                                    .bold()
                                    .padding(.horizontal)
                                    .font(.largeTitle)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                firstLaunch = false
                            })
                            .buttonStyle(.bordered)
                            .padding(.top, 10)
                        } else {
                                NavigationLink() {
                                    GameSceneView()
                                } label: {
                                    Text("Start")
                                        .bold()
                                        .padding(.horizontal)
                                        .font(.largeTitle)
                                }
                                .buttonStyle(.bordered)
                                .padding(.vertical, 10)
                                NavigationLink() {
                                    TutorialView()
                                } label: {
                                    Text("Tutorial")
                                        .bold()
                                        .padding(.horizontal)
                                        .font(.largeTitle)
                                }
                                .buttonStyle(.bordered)
                                .padding(.top, 10)
                            
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            // Disables hierarchical navigation, in favor of content driven navigation
            .frame(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
        }
    }
}

#Preview {
    MainMenuView()
}
