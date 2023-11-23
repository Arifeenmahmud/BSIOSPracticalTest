//
//  ContentView.swift
//  iOSPracticalTest
//
//  Created by Arifeen Mahmud on 22/11/23.
//

import SwiftUI

struct Movie: Codable {
    let title: String
    let overview: String
    let posterPath: String?

    var fullPosterPath: URL? {
        if let posterPath = posterPath, let posterURL = URL(string: "https://image.tmdb.org/t/p/w500" + posterPath) {
            return posterURL
        }
        return nil
    }
}

struct ContentView: View {
    @State private var movies: [Movie] = []

    var body: some View {
        NavigationView {
            VStack {
                Button("Load Data") {
                    loadData()
                }

                List(movies, id: \.title) { movie in
                    VStack(alignment: .leading) {
                        Text(movie.title)
                            .font(.headline)
                        Text(movie.overview)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        // Display movie poster using AsyncImage
                        if let posterPath = movie.fullPosterPath {
                            AsyncImage(url: posterPath) { phase in
                                switch phase {
                                case .empty:
                                    // Placeholder image while loading
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
                                    // Placeholder image on failure
                                    Image(systemName: "exclamationmark.square")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 200)
                                @unknown default:
                                    fatalError()
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle("Movie Search Results")
            }
        }
    }

    func loadData() {
        guard let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=38e61227f85671163c275f9bd95a8803&query=marvel") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(MovieResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.movies = result.results.map { movie in
                            Movie(title: movie.title, overview: movie.overview, posterPath: movie.posterPath)
                        }
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MovieResponse: Codable {
    let results: [Movie]
}
