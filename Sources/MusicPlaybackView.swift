//
//  MusicPlaybackView.swift
//  SampleMusicKit
//
//  Created by Viranaiken Jessy on 18/05/2026.
//

import SwiftUI
import MusicKit

struct MusicPlaybackView: View {
    
    @Environment(\.tabViewBottomAccessoryPlacement)
    var placement
    
    let artwork: Artwork
    let title: String
    let artist: String
    
    var body: some View {
        if placement == .inline {
            HStack {
                ArtworkComponentView(artwork: self.artwork, width: 50, height: 50)
                VStack {
                    Text(self.title)
                        .font(.headline)
                    Text(self.artist)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            
        }
    }
}
