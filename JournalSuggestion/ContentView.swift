//
//  ContentView.swift
//  JournalSuggestion
//
//  Created by Alkın Çakıralar on 21.01.2024.
//

import JournalingSuggestions
import MapKit
import SwiftUI

struct ContentView: View {
    @State private var journalInformation: JournalingSuggestion?
    @State private var contact: JournalingSuggestion.Contact?
    @State private var location: JournalingSuggestion.Location?

    var body: some View {
        NavigationStack {
            VStack {
                if let contact, let journalInformation {
                    ContactCardView(
                        title: journalInformation.title, date: journalInformation.date,
                        photo: contact.photo, name: contact.name
                    )
                }

                if let location, let journalInformation, let coordinate = location.location?.coordinate {
                    LocationCardView(title: journalInformation.title, date: journalInformation.date, coordinate: coordinate)
                }

                JournalingSuggestionsPicker("Present Journaling Suggestion Picker") { data in
                    let contact = await data.content(forType: JournalingSuggestion.Contact.self).first
                    let location = await data.content(forType: JournalingSuggestion.Location.self).first

                    withAnimation(.easeInOut(duration: 0.5)) {
                        journalInformation = data
                        self.contact = contact
                        self.location = location
                    }
                }
                .buttonStyle(.borderedProminent)
                .font(.headline)
                .padding(.bottom, 32)
            }
            .padding()
            .navigationTitle("Journal Suggestion")
        }
    }
}

func dayOfWeek(from interval: DateInterval?) -> String {
    guard let interval else { return "" }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter.string(from: interval.start)
}

func formatDate(from interval: DateInterval?) -> String {
    guard let interval else { return "" }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM d" // Format for "Month day"
    return dateFormatter.string(from: interval.start)
}

struct ContactCardView: View {
    let title: String
    let date: DateInterval?
    let photo: URL?
    let name: String

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.headline)
                    .bold()

                HStack(spacing: 4) {
                    Text(dayOfWeek(from: date))
                        .font(.caption)
                        .bold()

                    Text(formatDate(from: date))
                        .font(.caption)
                }

                HStack(alignment: .center, spacing: 12) {
                    AsyncImage(url: photo) { content in
                        content
                            .resizable()
                            .frame(width: 60, height: 60)
                            .presentationCornerRadius(30)
                    } placeholder: {
                        ProgressView()
                    }

                    Text(name)
                        .bold()
                        .font(.subheadline)
                }
                .padding()
                .background(Color.gray.opacity(0.5))
                .cornerRadius(10)
            }

            Spacer()
        }
    }
}

struct LocationCardView: View {
    let title: String
    let date: DateInterval?
    let coordinate: CLLocationCoordinate2D

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.headline)
                    .bold()

                HStack(spacing: 4) {
                    Text(dayOfWeek(from: date))
                        .font(.caption)
                        .bold()

                    Text(formatDate(from: date))
                        .font(.caption)
                }

                HStack(alignment: .center, spacing: 12) {
                    Map(
                        initialPosition: .camera(
                            .init(
                                centerCoordinate: coordinate,
                                distance: 5.5
                            )
                        )
                    )
                    .cornerRadius(10)
                    .frame(maxHeight: 300)
                }
                .padding()
                .background(Color.gray.opacity(0.5))
                .cornerRadius(10)
            }

            Spacer()
        }
    }
}
