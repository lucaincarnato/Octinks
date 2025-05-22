//
//  DeathScreen.swift
//  ProjectSquid
//
//  Created by Luca Maria Incarnato on 07/02/25.
//

import SwiftUI

struct DeathScreenView: View {
    var WIDTH: CGFloat = UIScreen.main.bounds.width
    var HEIGHT: CGFloat = UIScreen.main.bounds.height
    
    @Binding var deadOctopuses: Int // Match score from previous view
    @State var isWaiting: Bool = true // Shows information only when the animation has ended
    
    let deathTimer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect() // Determines the numbers' animation
    
    var body: some View {
        NavigationStack{
            // If the user clicks on the number it goes to the menu
            NavigationLink {
                MainMenuView()
            } label: {
                ZStack {
                    // Background image
                    Image("seabed")
                        .resizable()
                        .ignoresSafeArea()
                        .scaledToFill()
                    // Death stats UI
                    VStack {
                        if(!isWaiting){
                            Text("100 million marine animals dies every year from marine litter. While playing")
                                .font(.system(size: 45))
                                .foregroundStyle(Color.black)
                                .multilineTextAlignment(.center)
                        }
                        HStack{
                            if (!isWaiting) {
                                Image("deadGO")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 300, height: 300)
                            }
                            Text("\(deadOctopuses)")
                                .font(.system(size: 300))
                                .bold()
                                .foregroundStyle(isWaiting ? Color.purple : Color.black)
                            Text("\(isWaiting ? " +" : "")")
                                .font(.system(size: 300))
                                .bold()
                                .foregroundStyle(Color.black)
                            Text("\(isWaiting ? " 1" : "")")
                                .font(.system(size: 300))
                                .bold()
                                .foregroundStyle(Color.pink) // Not accentColor because when disabled it is not shown
                            if (!isWaiting) {
                                Image("squidGO")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 300, height: 300)
                            }
                        }
                        if(!isWaiting){
                            HStack{
                                Text("octopuses has been")
                                    .font(.system(size: 45))
                                    .foregroundStyle(Color.black)
                                Text("killed")
                                    .font(.system(size: 55))
                                    .bold()
                                    .foregroundStyle(Color.accentColor)
                            }
                            Text("Use your time wisely")
                                .font(.system(size: 45))
                                .bold()
                                .foregroundStyle(Color.accentColor)
                            Text("Touch the screen to replay")
                                .font(.headline)
                                .bold()
                                .foregroundStyle(Color.black.opacity(0.3))
                        }
                    }
                    // Waits two seconds to display the +1 animation
                    .onReceive(deathTimer) { _ in
                        if isWaiting {
                            deadOctopuses += 1
                            isWaiting.toggle()
                            deathTimer.upstream.connect().cancel()
                        }
                    }
                }
            }
            .disabled(isWaiting)
        }
    }
}

// https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://www.condorferries.co.uk/marine-ocean-pollution-statistics-facts%23:~:text%3D100%2520million%2520marine%2520animals%2520die,by%2520North%2520Pacific%2520fish%2520yearly.&ved=2ahUKEwi5jrHTjvaKAxUW-gIHHdrwCZwQFnoECBsQAw&usg=AOvVaw1xsevflaabjRD3LVkmthe1
