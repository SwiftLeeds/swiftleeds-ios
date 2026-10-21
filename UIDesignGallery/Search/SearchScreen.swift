import SwiftUI
import UIDesign

/// A view that finds a talk, a person or a sponsor in one place.
struct SearchScreen: View {
    /// Which kinds of result the list keeps.
    private enum Scope: Equatable, Hashable {
        /// Every kind at once.
        case everything

        /// One kind only.
        case only(SampleResult.Kind)
    }

    /// What this person has typed.
    @State private var query = ""

    /// Which kinds of result the list keeps.
    @State private var scope: Scope = .everything

    /// The screens pushed on top of Search.
    ///
    /// Search pushes several kinds of thing, a result, a person, a session and
    /// a sponsor, so the path is untyped.
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            found
                .navigationTitle("Search")
                .navigationDestination(for: SampleResult.self) { result in
                    destination(for: result)
                }
                // A person's page pushes the talks and the sponsor it names.
                .navigationDestination(for: SamplePerson.self) { person in
                    PersonScreen(person: person)
                }
                .navigationDestination(for: SampleSession.self) { session in
                    SessionDetailScreen(
                        session: session,
                        showSpeaker: { path.append($0) },
                    )
                }
                .navigationDestination(for: SampleSponsor.self) { sponsor in
                    SponsorScreen(sponsor: sponsor)
                }
        }
        .searchable(text: $query, prompt: "Talks, people and sponsors")
        // The picker waits for the first keystroke by default. Showing it as
        // search opens says what can be narrowed before anything is typed.
        .searchScopes($scope, activation: .onSearchPresentation) {
            Text("All").tag(Scope.everything)

            ForEach(SampleResult.Kind.allCases) { kind in
                Text(kind.heading).tag(Scope.only(kind))
            }
        }
    }

    /// What the screen shows: a prompt, nothing found, or the results.
    @ViewBuilder
    private var found: some View {
        if query.isEmpty {
            ContentUnavailableView(
                "Search SwiftLeeds",
                systemImage: "magnifyingglass",
                description: Text("Find a talk, a person or a sponsor."),
            )
        } else if matches.isEmpty {
            ContentUnavailableView.search(text: query)
        } else {
            results
        }
    }

    /// The results, grouped by the part of the conference they came from.
    private var results: some View {
        List {
            ForEach(SampleResult.Kind.allCases) { kind in
                let kept = matches.filter { $0.kind == kind }

                if !kept.isEmpty {
                    Section(kind.heading) {
                        ForEach(kept) { row($0) }
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    /// The results this query and this scope keep.
    private var matches: [SampleResult] {
        SampleResult.all.filter { kept($0.kind) && $0.matches(query) }
    }

    /// Returns whether the chosen scope keeps one kind of result.
    ///
    /// - Parameter kind: The part of the conference a result came from.
    private func kept(_ kind: SampleResult.Kind) -> Bool {
        switch scope {
        case .everything: true
        case .only(let only): only == kind
        }
    }

    /// Returns one result as a row that opens it.
    ///
    /// - Parameter result: The talk, person or sponsor the row names.
    private func row(_ result: SampleResult) -> some View {
        NavigationLink(value: result) {
            Nameplate {
                Text(marked(result.title))
            } detail: {
                Text(marked(result.detail))
            } icon: {
                icon(for: result)
            }
        }
    }

    /// Returns what stands for one result beside its name.
    ///
    /// A person takes an avatar, because search shows a person the way every
    /// other screen does. Everything else takes the symbol for its kind, at the
    /// same width, so the names stay in one column.
    ///
    /// - Parameter result: The talk, person or sponsor the row names.
    @ViewBuilder
    private func icon(for result: SampleResult) -> some View {
        if let person = result.person {
            Avatar(url: nil, size: .medium, fallback: .initials(person.nameComponents))
        } else {
            Image(systemName: result.kind.symbol)
                .font(.body)
                .foregroundStyle(.textSecondary)
                .frame(AvatarSize.medium)
        }
    }

    /// Returns text with the characters this person typed picked out.
    ///
    /// Only the first match is marked, which is the one a person is looking at.
    ///
    /// - Parameter text: The line to mark.
    private func marked(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        guard let range = attributed.range(of: query, options: .caseInsensitive) else {
            return attributed
        }
        attributed[range].foregroundColor = Color.brandPrimary
        return attributed
    }

    /// Returns the screen one result opens.
    ///
    /// - Parameter result: The talk, person or sponsor the row names.
    @ViewBuilder
    private func destination(for result: SampleResult) -> some View {
        if let session = result.session {
            SessionDetailScreen(
                session: session,
                showSpeaker: { path.append($0) },
            )
        } else if let person = result.person {
            PersonScreen(person: person)
        } else if let sponsor = result.sponsor {
            SponsorScreen(sponsor: sponsor)
        } else {
            NotYetDesigned(destination: .search)
                .navigationTitle(result.title)
        }
    }
}
