//
//  ShowsView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit

struct ShowsView: View, MediaRatingsLoader {
    static let theme = Theme()
    
    @StateObject var viewModel = ShowsViewModel()
    let columns = [
        GridItem(.adaptive(minimum: theme.itemWidth), spacing: theme.itemSpacing)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .leading) {
                errorView
                ScrollView {
                    LazyVGrid(columns: columns, spacing: ShowsView.theme.columnSpacing) {
                        ForEach(viewModel.shows, id: \.id) { show in
                            navigationLink(show: show)
                        }
                        if (!viewModel.shows.isEmpty) {
                            loadingView
                        }
                    }
                    .padding(.all, 0)
                    
                    if viewModel.isLoading && viewModel.shows.isEmpty {
                        ProgressView()
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    if viewModel.shows.isEmpty {
                        viewModel.loadShows()
                    }
                }
                #if os(tvOS)
                LeftSidePanelView(currentSort: $viewModel.currentFilter, currentGenre: $viewModel.currentGenre)
                    .padding(.leading, -50)
                #endif
            }
            #if os(macOS)
            .modifier(VisibleToolbarView(toolbarContent: { isVisible in
                ToolbarItem(placement: .navigation) {
                    if isVisible {
                        filtersView
                    }
                }
            }))
            #endif
            #if os(tvOS) || os(iOS)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                viewModel.appDidBecomeActive()
            }
            #endif
            #if os(iOS)
            .navigationBarHidden(false)
            .toolbar { filtersContent }
            #endif
        }
    }
    
    @ViewBuilder
    func navigationLink(show: Show) -> some View {
        NavigationLink(
            destination: ShowDetailsView(viewModel: ShowDetailsViewModel(show: show)),
            label: {
                ShowView(show: show)
            })
            .buttonStyle(PlainNavigationLinkButtonStyle(onFocus: {
                Task {
                    await loadRatingIfMissing(media: show, into: $viewModel.shows)
                }
            }))
            .padding([.leading, .trailing], 10)
    }
    
    @ViewBuilder
    var loadingView: some View {
        Text("")
            .onAppear {
                viewModel.loadMore()
            }
        if viewModel.isLoading {
            ProgressView()
        }
    }
    
    @ViewBuilder
    var errorView: some View {
        if let error = viewModel.error, viewModel.shows.isEmpty {
            HStack() {
                Spacer()
                ErrorView(error: error)
                    .padding(.bottom, 100)
                Spacer()
            }
        }
    }
    
    @ToolbarContentBuilder
    var filtersContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            HStack(spacing: 0) {
                Menu(
                    content: {
                        Text("Category")
                        ForEach(Popcorn.Filters.allCases, id: \.self) { item in
                            Button(
                                action: { viewModel.currentFilter = item },
                                label: {
                                    HStack {
                                        Text(item.string)
                                        if viewModel.currentFilter == item {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            )
                        }
                    },
                    label: {
                        HStack(spacing: 4) {
                            Text(viewModel.currentFilter.string)
                                .font(.headline)
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.secondary)
                                .font(.caption2)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .background(HierarchicalShapeStyle.tertiary, in: .capsule)
                    }
                )
                
                Menu(
                    content: {
                        Text("Genre")
                        ForEach(Popcorn.Genres.allCases, id: \.self) { item in
                            Button(
                                action: { viewModel.currentGenre = item },
                                label: {
                                    HStack {
                                        Text(item.string)
                                        if viewModel.currentGenre == item {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            )
                        }
                    },
                    label: {
                        HStack(spacing: 4) {
                            Text(viewModel.currentGenre.string)
                                .font(.headline)
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.secondary)
                                .font(.caption2)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .background(HierarchicalShapeStyle.tertiary, in: .capsule)
                    }
                )
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink(
                destination: { SearchView(viewModel: .init(selection: .shows)) },
                label: {Image(systemName: "magnifyingglass") }
            )
        }
    }
}

extension ShowsView {
    struct Theme {
        let itemWidth: CGFloat = value(tvOS: 240, macOS: 160)
        let itemSpacing: CGFloat = value(tvOS: 30, macOS: 20)
        let columnSpacing: CGFloat = value(tvOS: 60, macOS: 30)
    }
}

struct ShowsView_Previews: PreviewProvider {
    static var previews: some View {
        let model = ShowsViewModel()
        model.shows = Show.dummiesFromJSON()
        return ShowsView(viewModel: model)
            .preferredColorScheme(.dark)
            .accentColor(.white)
//            .previewInterfaceOrientation(.landscapeLeft)
    }
}
