//This is the start of 'ContentView.swift'
import SwiftUI

struct ContentView: View {
    @State private var cards: [Card] = []
    @State private var recentlySwipedCards: [Card] = []
    @State private var lastSwipedCard: Card?
    @State private var previousCard: Card? = nil
    @State private var remainingCards: Int = 0
    @State private var ratedMovies: [Card] = []
    @State private var isProfileViewPresented = false
    @State private var imageForMovie: [Card: UIImage] = [:]
    @State private var showRatePopup = false

    var body: some View {
        ZStack {
            VStack {
                // top stack
                HStack {
                    Button(action: {
//                        ratedMovies = []
                        lastSwipedCard = nil
                        previousCard = nil
                        recentlySwipedCards = []
                        isProfileViewPresented.toggle()
                    }) {
                        Image("profile")
                    }
                    Spacer()
                    Button(action: {}) {
                        Image("tinder-icon")
                            .resizable().aspectRatio(contentMode: .fit).frame(height: 45)
                    }
                    Spacer()
                    Button(action: {}) {
                        Image("chats")
                    }
                }
                .padding(.horizontal)

                // card
                ZStack {
                    ForEach(cards.indices, id: \.self) { index in
                        CardView(
                            card: cards[index],
                            recentlySwipedCards: $recentlySwipedCards,
                            previousCard: $previousCard,
                            remainingCards: $remainingCards,
                            ratedMovies: $ratedMovies,
                            showRatePopup: $showRatePopup,
                            updateRemainingCardsCount: updateRemainingCardsCount,
                            fetchMoviesIfNeeded: fetchMoviesIfNeeded
                        )
                        .padding(8)
                        .opacity(showRatePopup && lastSwipedCard?.id == cards[index].id ? 0 : 1) // Hide the card that was just swiped when the popup is shown
                        .onChange(of: recentlySwipedCards.count) { _ in
                            fetchMoviesIfNeeded()
                            }
                    }
                }
                .zIndex(showRatePopup ? 1 : 0)



                // bottom stack
                HStack(spacing: 100) {
                    Button(action: {}) {
                        Image("dismiss")
                    }
                    Button(action: {}) {
                        Image("like")
                    }
                }
            }
            .padding()

            if showRatePopup, let lastCard = lastSwipedCard {
                RateMoviePopupView(card: lastCard, showRatePopup: $showRatePopup, previousCard: $previousCard, recentlySwipedCards: $recentlySwipedCards, ratedMovies: $ratedMovies, updateRemainingCardsCount: updateRemainingCardsCount, fetchMoviesIfNeeded: fetchMoviesIfNeeded)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .transition(.move(edge: .bottom))
            }
            
        }
        .onAppear {
            fetchInitialMovies()
        }
        .sheet(isPresented: $isProfileViewPresented) {
            ProfileView(ratedMovies: ratedMovies)
        }
    }


    private func fetchInitialMovies() {
        // Fetch the first batch of movies (e.g., 5 movies)
        Card.fetchMovies(count: 5) { newCards in
            self.cards = newCards
            updateRemainingCardsCount()
        }
    }

    private func fetchMoviesIfNeeded() {
        // Check if we need to fetch more movies
        if remainingCards <= 2 {
            // Fetch more movies (e.g., 5 more movies)
            Card.fetchMovies(count: 5) { newCards in
                self.cards += newCards
                updateRemainingCardsCount()
            }
        }
    }

    private func updateRemainingCardsCount() {
        // Calculate the number of remaining cards
        remainingCards = max(0, cards.count - recentlySwipedCards.count - 1)
    }
}


struct CardView: View {
    @State private var image: UIImage?
    @ObservedObject var card: Card // Here
    @Binding var recentlySwipedCards: [Card]
    @Binding var previousCard: Card?
    @Binding var remainingCards: Int
    @Binding var ratedMovies: [Card]
    @Binding var showRatePopup: Bool // Add this bindin
    var updateRemainingCardsCount: () -> Void
    var fetchMoviesIfNeeded: () -> Void

    
    let cardGradient = Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.5)])

    var body: some View {
        ZStack(alignment: .topLeading) {
            getImage()

            LinearGradient(gradient: cardGradient, startPoint: .top, endPoint: .bottom)

            VStack {
                Spacer()
                VStack(alignment: .leading) {
//                    HStack {
//                        Text(card.original_title)
//                            .font(.largeTitle)
//                            .fontWeight(.bold)
//                        Text(card.release_date)
//                            .font(.title)
//                    }
                }
                .padding()
            }
        }
        .padding()
        .foregroundColor(.white)
        .cornerRadius(8)
        .offset(x: card.x, y: card.y)
        .rotationEffect(.init(degrees: card.degree))
        .gesture(
            DragGesture()
                .onChanged { value in
                    withAnimation(.default) {
                        card.x = value.translation.width
                        card.y = value.translation.height
                        card.degree = 7 * (value.translation.width > 0 ? 1 : -1)
                        if showRatePopup {
                            recentlySwipedCards.append(card)
                        }
                    }
                }
                .onEnded { value in
                    withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
                        switch value.translation.width {
                        case 0...100:
                            card.x = 0; card.degree = 0; card.y = 0
                        case let x where x > 100:
                            card.x = 500; card.degree = 12
                            showRatePopup = true
                            print("case is being hit")
                        case (-100)...(-1):
                            card.x = 0; card.degree = 0; card.y = 0;
                        case let x where x < -100:
                            card.x = -500; card.degree = -12
                        default: card.x = 0; card.y = 0
                        }

                        if showRatePopup {
                            print("if showratepopup yes")
                            previousCard = card
                        }
                        print("hit the functions")

                        updateRemainingCardsCount()
                        fetchMoviesIfNeeded()
                    }
                }
        )

        // Add the popup view here, outside the ZStack
        // Inside CardView, where you call RateMoviePopupView:
        if showRatePopup {
            RateMoviePopupView(card: card, showRatePopup: $showRatePopup, previousCard: $previousCard, recentlySwipedCards: $recentlySwipedCards, ratedMovies: $ratedMovies, updateRemainingCardsCount: updateRemainingCardsCount, fetchMoviesIfNeeded: fetchMoviesIfNeeded)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 4)
                .animation(.easeInOut(duration: 0.2))
                .transition(.move(edge: .bottom))
        }
    }

    private func getImage() -> AnyView {
        if let image = image {
            return AnyView(
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
            )
        } else {
            return AnyView(
                Image(systemName: "photo") // Show a placeholder image initially
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
                    .onAppear(perform: loadImage)
            )
        }
    }


    private func loadImage() {
        guard let urlString = card.poster_path,
              let url = URL(string: "https://image.tmdb.org/t/p/w500" + urlString)
        else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }.resume()
    }
}

struct RateMoviePopupView: View {
    @State var card: Card
    @Binding var showRatePopup: Bool
    @Binding var previousCard: Card?
    @Binding var recentlySwipedCards: [Card]
    @Binding var ratedMovies: [Card]
    var updateRemainingCardsCount: () -> Void
    var fetchMoviesIfNeeded: () -> Void
    @State private var rating: String = ""
    @State private var previousRating: String = ""
    @State private var previousCardPosition: CGSize = .zero
    @State private var previousCardDegree: Double = 0.0

    var body: some View {
        VStack(spacing: 60) {
            Text("Rate: \(card.original_title)")
                .font(.title3)
                .fontWeight(.bold)

            TextField("Enter rating", text: $rating)
                .onChange(of: rating) { newValue in
                    if let intValue = Int(newValue), intValue >= 1 && intValue <= 100 {
                        // valid value
                        previousRating = newValue
                    } else {
                        // invalid value, revert to previous valid value
                        rating = previousRating
                    }
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            

            HStack(spacing: 80) {
                Button("Not now") {
                    // Close the popup without rating
                    showRatePopup = false
                }
                Button("Submit") {
                    // Handle the submission of the rating
                    if !rating.isEmpty, let ratingValue = Int(rating), (1...100).contains(ratingValue) {
                        // You can perform the action you want with the valid rating here.
                        // For now, I'm just printing it to the console.
                        print("User rated movie '\(card.original_title)' with rating: \(ratingValue)")

                        // Close the popup after successful submission
                        card.rating = ratingValue
                        ratedMovies.append(card)
                        showRatePopup = false
                    } else {
                        // Display an alert or feedback to inform the user about invalid input
                        print("Invalid rating. Please enter a number between 1 and 100.")
                    }
                    updateRemainingCardsCount()
                    fetchMoviesIfNeeded()
                }
            }
            .onAppear {
                // Store the position and degree of the previous card when the popup appears
                recentlySwipedCards = []
            }
        }
        .frame(width: 300, height: 300) // Set a fixed width and height to make the popup larger
        .padding()
        .font(.title2)
        .cornerRadius(8)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
//This is the end of 'ContentView.swift'
