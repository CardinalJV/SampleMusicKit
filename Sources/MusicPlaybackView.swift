//
//  MusicPlaybackView.swift
//  SampleMusicKit
//
//  Created by Viranaiken Jessy on 18/05/2026.
//

import SwiftUI
import MusicKit

struct MusicPlaybackView: View {
    
    let musicPlayer = ApplicationMusicPlayer.self
    let artwork: Artwork?
    let playlist: Playlist?
    
    @State
    private var isPlaying = false
    @State
    private var songs: [Song] = []
    @State
    private var index = 0
    
    private var currentSong: Song? {
        if self.songs.isEmpty {
            return nil
        } else {
            return self.songs[self.index]
        }
    }
    
    private var songInfos: some View {
        HStack {
            ArtworkComponentView(artwork: self.artwork, width: 75, height: 75)
            VStack(alignment: .leading) {
                if let song = self.currentSong {
                    Text(song.title)
                        .font(.body)
                        .bold()
                    Text(song.artistName)
                        .font(.subheadline)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var previousButton: some View {
        Button {
            Task {
                try await self.musicPlayer.shared.skipToPreviousEntry()
                if self.index != 0 {
                    self.index -= 1
                }
            }
        } label: {
            Image(systemName: "arrowtriangle.up.2.fill")
                .padding()
                .rotationEffect(.degrees(-90))
                .font(.largeTitle)
        }
    }
    
    private var playButton: some View {
        Button {
            if self.isPlaying {
                Task {
                    self.musicPlayer.shared.pause()
                    self.isPlaying = false
                }
            } else {
                Task {
                    try await self.musicPlayer.shared.play()
                    self.isPlaying = true
                }
            }
        } label: {
            Image(systemName: self.isPlaying ? "pause.fill" : "play.fill")
                .font(.largeTitle)
                .padding()
        }
    }
    
    private var nextButton: some View {
        Button {
            Task {
                try await self.musicPlayer.shared.skipToNextEntry()
                if self.index != self.songs.count - 1 {
                    self.index += 1
                } else {
                    self.index = 0
                }
            }
        } label: {
            Image(systemName: "arrowtriangle.up.2.fill")
                .padding()
                .rotationEffect(.degrees(90))
                .font(.largeTitle)
        }
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                // Song infos
                self.songInfos
                // Player button
                HStack(spacing: 16) {
                    self.previousButton
                    self.playButton
                    self.nextButton
                }
                .padding()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
        .onAppear {
            self.index = 0
            if !self.songs.isEmpty {
                
            }
        }
        .task {
            if let playlist = self.playlist {
                if let songs = await self.loadPlaylistWithSongs(playlist) {
                    self.songs = songs
                    self.musicPlayer.shared.queue = ApplicationMusicPlayer.Queue(for: songs)
                }
            }
        }
        .onDisappear {
            self.musicPlayer.shared.stop()
        }
    }
    
    private func loadPlaylistWithSongs(_ playlist: Playlist) async -> [Song]? {
        do {
            let detailedPlaylist = try await playlist.with([.tracks])
            let songs = detailedPlaylist.tracks?.compactMap {
                if case .song(let song) = $0 { return song }
                return nil
            }
            return songs
        } catch {
            print("Error during loading playlist: \(error.localizedDescription)")
            return nil
        }
    }
    
    
}
