//
//  ContentView.swift
//  SampleMusicKit
//
//  Created by Viranaiken Jessy on 18/05/2026.
//

import SwiftUI
import MusicKit

struct ContentView: View {
    
    @State
    private var query: String = ""
    @State
    private var playlists: [Playlist] = []
    @State
    private var isSearching = false
    @State
    private var errorMessage: String?
    @State
    private var musicAuthorized = false
    @State
    private var showError = false
    
    var body: some View {
        NavigationStack {
            List(self.playlists) { playlist in
                HStack {
                    if let itemArtwork = playlist.artwork {
                        ArtworkComponentView(artwork: itemArtwork, width: 75, height: 75)
                    } else {
                        Image(systemName: "music.note.list")
                            .frame(width: 75, height: 75)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    VStack(alignment: .leading) {
                        Text(playlist.name)
                            .font(.headline)
                        if let curatorName = playlist.curatorName {
                            Text(curatorName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Apple Music Playlists")
            .searchable(text: self.$query, prompt: "Search playlists")
        }
        .tabViewBottomAccessory(content: {
            MusicPlaybackView()
        })
        .onAppear {
            Task {
                await self.requestMusicAuthorization()
                try await self.fetchMainPlaylists(year: 2010)
            }
        }
    }
    
    private func fetchMainPlaylists(year: Int) async throws {
        let decade = (year / 10) * 10
        
        var request = MusicCatalogSearchRequest(
            term: "\(decade)s",
            types: [Playlist.self]
        )
        request.limit = 25
        
        let response = try await request.response()
        
        self.playlists = response.playlists.filter { playlist in
            playlist.curatorName == "Apple Music" &&
            playlist.name.contains("\(decade)")
        }
    }
    
    private func requestMusicAuthorization() async {
        let status = await MusicAuthorization.request()
        switch status {
        case .authorized:
            self.musicAuthorized = true
        case .denied:
            self.musicAuthorized = false
        case .notDetermined:
            self.showError = true
        case .restricted:
            self.showError = true
        @unknown default:
            break
        }
    }
}

#Preview {
    ContentView()
}
