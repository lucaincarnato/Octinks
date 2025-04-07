//
//  InkBar.swift
//  ProjectSquid
//
//  Created by Luca Maria Incarnato on 12/02/25.
//

import SwiftUI

struct InkBar: View {
    var progress: Float // Valore tra 0.0 e 1.0 che indica il riempimento
    
    var body: some View {
        ZStack {
            // Sprite che rappresenta il contorno
            Image("inkEmpty")
                .resizable()
                .aspectRatio(contentMode: .fit)
            // Rettangolo di riempimento
            GeometryReader { geometry in
                let height = geometry.size.height
                let progressHeight = height * CGFloat(progress)
                
                VStack(spacing: 0) {
                    Spacer() // Spazio vuoto per mantenere il riempimento dal basso verso l'alto
                    Rectangle()
                        .fill(Color.black) // Colore di riempimento
                        .frame(height: progressHeight)
                }
            }
            .mask(
                // Applichiamo la maschera basata sul contorno
                Image("inkFull")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            )
        }
    }
}
