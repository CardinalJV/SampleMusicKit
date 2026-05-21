//
//  MusicPlaybackView.swift
//  SampleMusicKit
//
//  Created by Viranaiken Jessy on 18/05/2026.
//

import SwiftUI
import MusicKit

struct MusicPlaybackView: View {
    
    @Environment(\.scenePhase)
    private var scenePhase
    @Environment(\.dismiss)
    private var dismiss
    let musicPlayer = ApplicationMusicPlayer.shared
    let artwork: Artwork?
    let playlist: Playlist?
    
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
    
//    private var isPlaying: Bool {
//        return self.musicPlayer.state.playbackStatus == .playing
//    }
    
    @State
    private var isPlaying = false
    @ViewBuilder
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
            Image(systemName: "waveform")
                .font(.title)
                .symbolEffect(.variableColor, options: .repeat(.continuous), isActive: self.isPlaying)
        }
        .frame(maxWidth: .infinity)
    }
    @ViewBuilder
    private var previousButton: some View {
        Button {
            Task {
                try await self.musicPlayer.skipToPreviousEntry()
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
    @ViewBuilder
    private var playButton: some View {
        Button {
            if self.isPlaying {
                self.isPlaying = false
                Task {
                    self.musicPlayer.pause()
                }
            } else {
                self.isPlaying = true
                Task {
                    try await self.musicPlayer.play()
                }
            }
        } label: {
            Image(systemName: self.isPlaying ? "pause.fill" : "play.fill")
                .font(.largeTitle)
                .padding()
        }
    }
    @ViewBuilder
    private var nextButton: some View {
        Button {
            Task {
                try await self.musicPlayer.skipToNextEntry()
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
                .foregroundStyle(.primary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            self.index = 0
        }
        .task {
            if let playlist = self.playlist {
                if let songs = await self.loadPlaylistWithSongs(playlist) {
                    self.songs = songs
                    self.musicPlayer.queue = ApplicationMusicPlayer.Queue(for: songs)
                }
            }
        }
        // MARK: - Reset when the app statement change
        .onChange(of: scenePhase) {
            self.stopAndClearPlayer()
            self.dismiss()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.protectedDataWillBecomeUnavailableNotification
            )
        ) { _ in
            self.stopAndClearPlayer()
            self.dismiss()
        }
        .onDisappear {
            self.stopAndClearPlayer()
        }
    }
    
    private func stopAndClearPlayer() {
        self.musicPlayer.stop()
        self.musicPlayer.queue.entries.removeAll()
        self.isPlaying = false
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
