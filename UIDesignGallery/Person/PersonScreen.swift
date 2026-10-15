import SwiftUI
import UIDesign

/// A view that shows who a person is, what they speak about and where to
/// find them.
///
/// Every section below the header appears only when the person has something
/// for it.
struct PersonScreen: View {
    /// The most lines the bio takes until a person asks for the rest.
    private static let collapsedBioLines = 4

    /// The person this screen describes.
    let person: SamplePerson

    /// Whether the person is saved.
    @State private var isSaved: Bool

    /// Whether the bio shows in full.
    @State private var isBioExpanded: Bool

    /// How tall the bio is when it shows in full.
    @State private var fullBioHeight: CGFloat = 0

    /// How tall the bio is when it is cut to its first lines.
    @State private var cutBioHeight: CGFloat = 0

    /// Whether this person has asked to reduce motion.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Creates a screen for one person.
    ///
    /// - Parameters:
    ///   - person: The person this screen describes.
    ///   - opensSaved: Whether the person is already saved when the screen
    ///     appears.
    ///   - opensBioExpanded: Whether the bio shows in full when the screen
    ///     appears.
    init(
        person: SamplePerson,
        opensSaved: Bool = false,
        opensBioExpanded: Bool = false,
    ) {
        self.person = person
        _isSaved = State(initialValue: opensSaved)
        _isBioExpanded = State(initialValue: opensBioExpanded)
    }

    var body: some View {
        List {
            Section {
                header
                    .listRowInsets(EdgeInsets())
                    // The header is the screen's subject, not one of its rows,
                    // so it sits on the page rather than on a card.
                    .listRowBackground(Color.clear)
            }

            talksThisYear
            previousTalks
            company
            about
            links
        }
        .listStyle(.insetGrouped)
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                saveButton
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .tint(.textPrimary)
            }
        }
    }
}

// MARK: - Header

extension PersonScreen {
    /// Who this person is, and what the conference calls them.
    ///
    /// The avatar takes an edge, because a placeholder on a surface of the
    /// same color needs one to be seen. It is hidden from VoiceOver, because
    /// the name sits directly below it. The rest reads as one element: the
    /// name, the detail, then each role once.
    private var header: some View {
        VStack(spacing: .medium) {
            Avatar(url: nil, size: .xLarge, fallback: .initials(person.nameComponents))
                .overlay {
                    Circle().strokeBorder(.borderPrimary, lineWidth: CGFloat(BorderWidth.thin))
                }
                .accessibilityHidden(true)

            VStack(spacing: .xxSmall) {
                Text(person.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.textPrimary)

                Text(person.detail)
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
            }

            badges
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(.horizontal, .large)
        .padding(.vertical, .large)
        .accessibilityElement(children: .combine)
    }

    /// The standings this person holds, side by side while they fit.
    private var badges: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: .small) {
                roleBadges
            }

            VStack(spacing: .small) {
                roleBadges
            }
        }
    }

    /// One badge for each standing this person holds.
    private var roleBadges: some View {
        ForEach(person.roles.all, id: \.name) { role in
            MockRoleBadge(role: role)
        }
    }
}

// MARK: - Toolbar

extension PersonScreen {
    /// The button that saves this person, or takes them off the saved list.
    private var saveButton: some View {
        Button {
            toggleSaved()
        } label: {
            Label {
                Text(isSaved ? "Unsave" : "Save")
            } icon: {
                Image(systemName: isSaved ? "star.fill" : "star")
                    .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
            }
        }
        .tint(.textPrimary)
        .sensoryFeedback(.success, trigger: isSaved)
    }

    /// Saves this person, or takes them off the saved list.
    ///
    /// The symbol replaces itself with an animation, unless this person has
    /// asked to reduce motion.
    private func toggleSaved() {
        if reduceMotion {
            isSaved.toggle()
        } else {
            withAnimation { isSaved.toggle() }
        }
    }
}

// MARK: - Sections

extension PersonScreen {
    /// The talks this person gives at this year's conference.
    @ViewBuilder
    private var talksThisYear: some View {
        let talks = person.talksThisYear

        if !talks.isEmpty {
            Section("Speaking this year") {
                ForEach(talks) { session in
                    NavigationLink(value: session) {
                        TalkRow(session: session)
                    }
                    // A pale tint lifts the talks above the rest of the page.
                    .listRowBackground(Color.brandPrimary.opacity(Self.talkTint))
                }
            }
        }
    }

    /// How faint the tint behind a talk this year is.
    private static let talkTint: Double = 0.08

    /// The talks this person gave at earlier conferences.
    @ViewBuilder
    private var previousTalks: some View {
        let talks = person.previousTalks

        if !talks.isEmpty {
            Section("Previous talks") {
                ForEach(talks) { session in
                    NavigationLink(value: session) {
                        previousTalk(session)
                    }
                }
            }
        }
    }

    /// Returns a plain row for a talk from an earlier conference.
    ///
    /// - Parameter session: The talk the row describes.
    private func previousTalk(_ session: SampleSession) -> some View {
        VStack(alignment: .leading, spacing: .xxSmall) {
            Text(session.title)
                .font(.headline)
                .foregroundStyle(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(session.conference)
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
        }
    }

    /// The sponsor this person speaks for, if any.
    @ViewBuilder
    private var company: some View {
        if let sponsor = person.represents {
            Section("Company") {
                NavigationLink(value: sponsor) {
                    SponsorRow(sponsor: sponsor)
                }
            }
        }
    }

    /// What this person says about themselves, if anything.
    @ViewBuilder
    private var about: some View {
        if let bio = person.bio {
            Section("About") {
                bioText(bio)

                if isBioCut || isBioExpanded {
                    Button(isBioExpanded ? "See less" : "See more") {
                        isBioExpanded.toggle()
                    }
                    .buttonStyle(.plain)
                    .font(.body)
                    .foregroundStyle(.brandPrimary)
                }
            }
        }
    }

    /// Whether the bio is longer than the lines it shows until expanded.
    private var isBioCut: Bool {
        fullBioHeight > cutBioHeight
    }

    /// Returns the bio, cut to its first lines until it is expanded.
    ///
    /// Two hidden copies measure the bio in full and cut, so the button shows
    /// only when there is something more to read. VoiceOver reads the whole
    /// string whether or not the text is cut.
    ///
    /// - Parameter bio: What the person says about themselves.
    private func bioText(_ bio: String) -> some View {
        Text(bio)
            .font(.body)
            .foregroundStyle(.textPrimary)
            .lineLimit(isBioExpanded ? nil : Self.collapsedBioLines)
            .fixedSize(horizontal: false, vertical: true)
            .background {
                measure(bio, lines: nil, into: $fullBioHeight)
                measure(bio, lines: Self.collapsedBioLines, into: $cutBioHeight)
            }
    }

    /// Returns an invisible copy of the bio that reports its height.
    ///
    /// - Parameters:
    ///   - bio: What the person says about themselves.
    ///   - lines: The most lines the copy takes, or `nil` for no limit.
    ///   - height: Where the copy's height goes.
    private func measure(
        _ bio: String,
        lines: Int?,
        into height: Binding<CGFloat>,
    ) -> some View {
        Text(bio)
            .font(.body)
            .lineLimit(lines)
            .fixedSize(horizontal: false, vertical: true)
            .hidden()
            .accessibilityHidden(true)
            .onGeometryChange(for: CGFloat.self) {
                $0.size.height
            } action: { new in
                height.wrappedValue = new
            }
    }

    /// The pages this person publishes, if any.
    @ViewBuilder
    private var links: some View {
        if !person.links.isEmpty {
            Section("Links") {
                ForEach(person.links) { link in
                    ResourceRow(resource: link.resource)
                }
            }
        }
    }
}
