//
//  ContentView.swift
//  iOSPracticalTest
//
//  Created by Arifeen Mahmud on 22/11/23.
//

import SwiftUI

struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let backdropPath: String?
    let posterPath: String?

    var fullBackdropPath: URL? {
        return constructImageURL(imagePath: backdropPath)
    }

    var fullPosterPath: URL? {
        return constructImageURL(imagePath: posterPath)
    }

    private func constructImageURL(imagePath: String?) -> URL? {
        guard let imagePath = imagePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500" + imagePath)
    }
}

class MovieViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var filteredMovies: [Movie] = []

    func searchMovies(query: String) {
        guard !query.isEmpty else {
            filteredMovies = movies
            return
        }

        filteredMovies = movies.filter { movie in
            movie.title.lowercased().contains(query.lowercased())
        }
    }

    func fetchMovies() {
        guard let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=38e61227f85671163c275f9bd95a8803&query=marvel") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(MovieResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.movies = result.results
                        self.filteredMovies = self.movies // Initialize filteredMovies with all movies
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
}

struct MovieListView: View {
    @ObservedObject var viewModel = MovieViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search", text: $searchText, onCommit: {
                    viewModel.searchMovies(query: searchText)
                })
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

                List(viewModel.filteredMovies) { movie in
                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                        MovieCell(movie: movie)
                    }
                }
                .navigationBarTitle("Movie Search Results")
            }
            .onAppear {
                viewModel.fetchMovies()
            }
        }
    }
}

struct MovieCell: View {
    var movie: Movie

    var body: some View {
        HStack {
            AsyncImage(url: movie.fullBackdropPath ?? URL(string: "")) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .foregroundColor(.gray)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                case .failure:
                    Image(systemName: "exclamationmark.square")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .foregroundColor(.gray)
                @unknown default:
                    fatalError()
                }
            }

            VStack(alignment: .leading) {
                Text(movie.title)
                    .font(.headline)
                Text(movie.overview)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct MovieDetailView: View {
    var movie: Movie

    var body: some View {
        VStack {
            AsyncImage(url: movie.fullBackdropPath ?? URL(string: "")) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                case .failure:
                    Image(systemName: "exclamationmark.square")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                @unknown default:
                    fatalError()
                }
            }

            VStack(alignment: .leading) {
                Text(movie.title)
                    .font(.title)
                    .padding(.top, 10)
                Text(movie.overview)
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle(movie.title)
    }
}

struct MovieResponse: Codable {
    let results: [Movie]
}

@main
struct MovieApp: App {
    var body: some Scene {
        WindowGroup {
            MovieListView()
        }
    }
}
