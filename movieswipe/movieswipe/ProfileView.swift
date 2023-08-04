//This is the start of 'ProfileView.swift'
import SwiftUI

struct ProfileView: View {
    var ratedMovies: [Card] // Remove the @Binding property wrapper

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(ratedMovies) { movie in // Now you're using the array directly
                        HStack {
                            
                            VStack(alignment: .leading) {
                                Text(movie.original_title)
                                    .font(.headline)
                                Text("Rating: \(movie.rating)")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
            }, label: {
                Image(systemName: "arrow.left")
                    .foregroundColor(.black)
                    .font(.title)
            }))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Rated Movies")
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(ratedMovies: []) // Pass an empty array of ratedMovies
    }
}
//This is the end of 'ProfileView.swift'
