import UIKit
import Foundation


//MARK: - DATA
struct MovieData: Codable {
    let poster_path: String?
    let id: Int
    let original_title: String
    let release_date: String
}

struct Response: Codable {
    let results: [MovieData]
}

class Card: ObservableObject, Identifiable, Hashable {
    let id: Int
    let original_title: String
    let poster_path: String?
    let release_date: String
    @Published var isSeen: Bool = false
    @Published var x: CGFloat = 0.0
    @Published var y: CGFloat = 0.0
    @Published var degree: Double = 0.0
    @Published var rating: Int = 0

    static var data: [Card] = [] // Empty array to store fetched movie data from API
    
    init(id: Int, original_title: String, poster_path: String?, release_date: String) {
        self.id = id
        self.original_title = original_title
        self.poster_path = poster_path
        self.release_date = release_date
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.id == rhs.id
    }

}

extension Card {
    static func fetchMovies(count: Int, completion: @escaping ([Card]) -> Void) {
        let apiKey = "d94f6ed94bd565126a387795d3c6b3b8"
        let urlString = "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion([])
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                let movies = response.results

                // Choose movies based on the count parameter or the remaining count, whichever is smaller
                var randomMovies: ArraySlice<MovieData>
                if count <= movies.count {
                    randomMovies = movies.shuffled().prefix(count)
                } else {
                    let remainingCount = count - movies.count
                    let remainingMovies = movies.shuffled().prefix(remainingCount)
                    randomMovies = (movies + Array(remainingMovies)).shuffled().prefix(count)
                }

                let cards = randomMovies.compactMap { movie -> Card? in
                    guard let posterPath = movie.poster_path else { return nil }
                    return Card(id: movie.id, original_title: movie.original_title, poster_path: posterPath, release_date: movie.release_date)
                }

                DispatchQueue.main.async {
                    self.data = cards
                    completion(cards)
                }
            } catch {
                print("Error decoding JSON: \(error)")
                completion([])
            }
        }.resume()
    }
}
