//
//  ArtworkComponentView.swift
//  SampleMusicKit
//
//  Created by Viranaiken Jessy on 18/05/2026.
//

import SwiftUI
import MusicKit

struct ArtworkComponentView: View {
    
    let artwork: Artwork
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        AsyncImage(url: artwork.url(width: 150, height: 150)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: self.width, height: self.height)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        } placeholder: {
            ProgressView()
                .frame(width: self.width, height: self.height)
        }
    }
}
