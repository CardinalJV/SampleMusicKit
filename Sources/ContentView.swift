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
    private var selectedPlaylist: Playlist?
    @State
    private var isSearching = false
    @State
    private var errorMessage: String?
    @State
    private var musicAuthorized = false
    @State
    private var showError = false
    @State
    private var showMusicView = false
    @State
    private var filterByYear: Int?
    
    let years: [Int] = [1960, 1970, 1980, 1990, 2000, 2010, 2020]
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                ForEach(self.years, id: \.self) { year in
                    Button(String(year)) {
                        self.filterByYear = year
                    }
                    .foregroundStyle(self.filterByYear == year ? .blue : .primary)
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .foregroundStyle((self.filterByYear != nil) ? Color.blue : Color.primary )
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(self.playlists) { playlist in
                Button {
                    self.selectedPlaylist = playlist
                    self.showMusicView = true
                } label: {
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
                    .padding()
                }
            }
            .navigationTitle("Apple Music Playlists")
            .searchable(text: self.$query, prompt: "Search playlists")
            .navigationDestination(isPresented: self.$showMusicView) {
                if let playlist = self.selectedPlaylist {
                    MusicPlaybackView(artwork: playlist.artwork, playlist: playlist)
                }
            }
            .toolbar {
                self.toolbarContent
            }
        }
        .onAppear {
            Task {
                await self.requestMusicAuthorization()
                try await self.fetchMainPlaylists(year: 2010)
            }
        }
        .onChange(of: self.filterByYear) {
            Task {
                if let year = self.filterByYear {
                    try await self.fetchMainPlaylists(year: year)
                }
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
