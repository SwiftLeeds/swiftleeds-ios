---
paths:
  - "**/*.swift"
---

# Swift conventions for this repo

This file holds what is specific to this codebase, or not yet promoted to a wider rule. Compiled
2026-08-22; dated claims are point-in-time, verify against current code.

## Structure

- **A SwiftUI view model nests under its view** as `ViewModel`, declared in an extension, held as
  `@State private var viewModel = ViewModel()`. `@Observable` plus `@State`, never
  `ObservableObject`/`@StateObject`.
- **The view model lives in its own file, beside the view**: `<View>/<View>.swift` and
  `<View>/<View>+ViewModel.swift`, as `AccountView` does. Never in the view's file. Decided
  2026-09-16. `SponsorsView` still breaks this.
- **Exception: an iOS-only view's view model stays top level and unguarded.** A view inside
  `#if canImport(UIKit)` does not exist on macOS, so nesting under it would force the guard onto the
  view model and stop CI's macOS job from testing it. Name it `<View>Model`, as `AboutViewModel`.
  Never import UIKit or Combine into a view model. Decided 2026-09-21; the aim is to make
  such a view cross-platform later and then nest the view model.
- **Keep an Application-layer use case even when it is a pure pass-through** (`FetchProfile`
  forwarding to `AttendeeRepository.fetch`). Uniformity wins over the "no boundary without a
  benefit" lean; this is an explicit preference.
- **Local packages live under `Packages/<Folder>/`**, added to the Xcode project as a `Packages` group
  with four subgroups (`DesignSystem`, `Feature`, `FeatureUI`, `Kit`), each package a wrapper file
  reference. `Packages/*/*/Package.resolved` is **committed**
  (PR #116) and must be pinned to the workspace's versions. The workspace's
  `SwiftLeeds.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` is the source of
  truth: after adding a dependency, run `swift package resolve --package-path Packages/<Folder>/<Name>
  --scratch-path "$PWD/.build-shared"` from the repository root first, then take the workspace's
  versions for the pins the package shares with it. Keep Xcode's file format (sorted keys, a space
  before each colon, a final newline), or the next Apple tool to open the project rewrites the whole
  file.
- **Folder-by-type moves get their own PR**, never ride a feature. Tests mirror the source
  hierarchy by **subject, not filename**. Grep for hard-coded paths (generators, scripts, CI)
  before finishing a move.

## swift-dependencies

- **Live implementations read `@Dependency(\.x)` inside each endpoint closure**, resolved at call
  time. Tests override with `withDependencies { $0.x = spy } operation: { ... }`, constructing
  and exercising the sut inside the operation. Explicit-factory injection was tried
  (`SessionStore.backed(by:)`) and reverted; standardisation and composability won.
- **Register a dependency only when something resolves it.** No `DependencyKey`/`testValue` until
  a consumer does `@Dependency(\.x)`. Until then a plain `static var live` factory is enough.
- **Typed-throws closure-struct gotcha:** `unimplemented(_:)` cannot throw through a typed
  signature with a non-`Void` return. Hand-write the `testValue` closure with an explicit
  signature so typed-throw inference works:
  `{ () async throws(E) -> T in reportIssue("X.y is unimplemented"); throw .someCase }`.
  Without the explicit signature, a multi-statement closure infers `throws(any Error)`.

## Naming closure-structs

The discriminator is **action or collaborator**, never arity (agreed 2026-08-17):

- **An action gets a verb-phrase name and `callAsFunction`**: `SignIn`, `SignOut`, `FetchProfile`.
  `Log` takes the same form but is a cross-cutting infrastructure port, not a use case; the verb
  form marks an action, not a layer.
- **A collaborator keeps a noun name and a named member**: `HTTPClient`, `SecureStorage`,
  `AttendeeMapper`. `HTTPClient` has one member and is correctly a noun; arity proves nothing.
- **Avoid adjective-plus-noun type names** (`CurrentAuthStatus`): they read as data while holding
  a function. `AuthStatus` is a recorded outlier, kept for API stability, not a precedent.
- **Why not `callAsFunction` everywhere:** it hides the operation from `.`-completion; a named
  member like `.map` is findable. Accept the mild `mapper.map` stutter.
- **Name a decorator for the guarantee it establishes, not the mechanism.**
  `throwingOnlyAuthenticationError()`, not `narrowingFailures()`. Clarity beats brevity.
- **A conversion protocol lives with its consumer and conformers**, not with the type it names.
  `AuthenticationErrorConvertible` belongs in Infrastructure, `internal`.

## Vocabulary

**Two vocabularies, split at the anti-corruption boundary.** The backend says login; we say sign
in. Types naming a wire artifact take the backend's word (`LoginRequestDTO`, `LoginMapper`,
`Endpoint.login`); types naming our operation take ours (`SignIn`, `SignInError`).

## Boundaries

**No external concern ever touches a domain type. Logging is an external concern** (2026-08-17).
Persistence, transport, serialisation, logging, analytics: a domain type must not
conform to their protocols, import their modules, or gain a property for their benefit. The
alternative is always a mapped type in Infrastructure, like `CachedSession` for the Keychain.
Trap: a logging DTO must never take its value from `description`; build it from the real value
via the extraction initialiser.

**Name a mapped type for where it goes.** Decided 2026-10-14.

| The type is | Name | Examples |
|---|---|---|
| Sent to or received from the network | `<Name>DTO` | `LoginRequestDTO`, `AttendeeDTO`, `SponsorListDTO` |
| Persisted to local storage (Keychain, disk) | `Cached<Name>` | `CachedSession` |

- **Check where the value goes before naming it.** A type that only meets the Keychain is not a
  DTO, even though both are `Codable` shapes in Infrastructure. PR #234 renamed `CachedSession` to
  `StoredSessionDTO` and was closed for exactly this.
- **A persisted type maps both ways, and the way back can fail**: `Session` to `CachedSession` to
  `Session?`. Stored data can be stale or corrupt, so it is parsed again into the domain type, and
  failure means "nothing stored".
- **So its fields may stay bare primitives**, like a DTO's: the round trip re-validates them.
- `...DTO` may become `Remote...` later. Until then, `DTO` means network.

**Log privacy lives in the logger, not the type.** Do not add `•••` redaction to `description`;
classify fields at the log seam instead.

**Ask where a line will be read before deciding it is worth writing.** The only destination composed
here is `Log.unified`, which writes to OSLog on the device. There is no remote log, no crash reporter
and no analytics, so a line recording something that happens to a user in the field reaches nobody.
Decided 2026-08-26, closing a PR that logged a barcode failure at a conference door. Pair it with the
existing test: can our design produce this error on conforming input? A line that fails both is
documentation, not diagnosability.

**But shape an existing line's content for the designed destination set, not today's.** Correction,
2026-08-27: LogKit is multi-destination by design, and a remote destination is the
intended future. Whether a line is worth writing is judged by today's readers (above); what a
surviving line carries is judged by the destinations the design allows. Prefer structured fields a
backend can query and facet over prose only a human can grep.

## Types before hand-rolled checks

**Reach for an established data structure before writing an invariant in prose or defensive
code.** The tell: a doc comment stating a rule, or code compensating for a state the type
permits. The shelf, in rough order:

| Requirement | Reach for |
|---|---|
| Unique keys, insertion order kept | `OrderedDictionary` (`swift-collections`) |
| Unique elements, insertion order kept | `OrderedSet`; careful, it dedupes on the whole element |
| Never empty | `NonEmpty`, or a `(head, tail)` pair |
| Collection with a guaranteed valid selection | zipper / `Selection` |
| Alternating `a, b, a, b, a` | `(first: A, rest: [(B, A)])` |
| Two kinds that must not be confused | a sum type, never a string convention or reserved prefix |
| A value that must satisfy a rule | a parsed wrapper with a throwing init |

**A sum type beats a naming convention**: a reserved-character parser is defeated by any new
entry point; an enum cannot be. **Weigh each new dependency honestly and pin it**;
`swift-collections` was not in the graph as of 2026-08-17.

**Identity is assigned by the system; anything the caller supplies is data.** If two things must
never be confused, ask who chooses the discriminator. If the answer is the caller, it is data and
cannot be trusted to be unique. Give the system-assigned identity its own type callers cannot
construct, and let the caller's string be a label hanging off it. (Learned from a real defect: a
caller's `name:` used as a message gap's identity let a `secret` value print in full.)

## API design: progressive disclosure

From "The craft of SwiftUI API design: Progressive disclosure", WWDC22 session 10059. Approved
2026-09-25. This extends the vendored `swift-api-design-guidelines` skill, which the skill manager
pins by hash, so the rule lives here.

**The definition**: "designing APIs so that the complexity of the call site grows with the
complexity of the use case."

**Judge from the call site, never the declaration.** We write code from the declaration site, and
it reads well or badly where it gets used.

Four strategies, in Apple's words:

1. **Consider common use cases.** `Button("Next Page") { }` covers the common case; a trailing
   `label:` closure covers the rest. "99% percent of the time, you only need the simple version."
2. **Provide intelligent defaults.** `Text("Hello")` already localizes, follows the color scheme
   and scales with Dynamic Type, with none of it at the call site.
3. **Optimise the call site.** The test Apple applies to its finished `Table`: "Every character of
   this call site serves a clear purpose."
4. **Compose, do not enumerate.**

**Ask two questions at every step**: what are the most common use cases we should build
conveniences for, and what is the essential information that should always be required? Apple's own
caution: "They need to be applied carefully. If you don't think through their implications for your
API, they can lead you astray."

### Compose, do not enumerate

**An enum of arrangements is the smell.** Apple's worked example adds an `arrangement` enum to
`HStack`, then watches it fail as soon as more spacing behaviours are wanted: "I have to add an enum
case for every behavior we want, and we might not think of all the useful cases!"

**The rule**: "When you find yourself enumerating common cases rather than providing conveniences
for them, try breaking your API apart into composable pieces that can build a solution." `Spacer` is
SwiftUI's answer, and it covers every case the enum listed plus many it did not.

This sits beside the rule against adding structure nobody asked for, from the other direction: that
rule says do not add a piece nobody asked for, and this one says when a growing list of cases means
the piece you have is the wrong shape.

## Comments: the discriminators

The general rule is to comment rationale, never the code. These tests decide the hard cases:

- **Is the fact older than the change?** Every comment worth deleting stated something decided in
  the same turn as the code beneath it; that justification belongs in the commit message. A fact
  that predated the change is one the reader cannot reconstruct, so it earns its place.
- **Delete any doc sentence containing "because", "without this", "deliberately", or a fact about
  the past.** Those mark maintainer rationale with near-perfect accuracy. What survives is what
  the thing is, plus an example.
- **If a comment warns a future maintainer, write the test instead.** The test cannot go stale
  and fires at the moment of the mistake.
- **A protocol doc never lists its conformers.** Describe the contract and the cost of getting it
  wrong; DocC generates the roster.
- **Deleting a declaration means re-reading every comment that mentions it** and asking whether
  each still has a subject, not whether it can be reworded true.
- Where content goes:

| Content | Home |
|---|---|
| What it is, returns, throws | doc comment |
| A constraint the caller cannot infer | doc comment |
| Why we built it this way | commit message |
| How it relates to sibling types | nowhere; the types show it |
| An architectural principle | a design note, not a code comment |

## Layout residue

- **Do not rewrite existing code for one-case-per-line.** Apply it to new code; tidy surrounding
  cases only when already refactoring that type.

## Silencing a lint rule

**`swiftlint:disable` is allowed, for legacy code we then remove or rewrite to meet the standard.**
Decided 2026-09-24, when turning on `discouraged_optional_collection`. It marks work, not an
exemption: every suppression carries a reason and is tracked as work to remove.

- **Use `swiftlint:disable:this`**, on the offending line itself. Never a region: a bare
  `swiftlint:disable` silences the rule for the rest of the file, so a later violation slips in
  unnoticed. `:this` names one line and keeps the suppression where the reader can see what it
  covers. Decided 2026-09-24. Fall back to `:next` only where the line has no room, and
  say why. The one region allowed is below, under `no_magic_numbers`.
- **State the reason in plain English**, in the line above, or on the command itself after
  SwiftLint's ` - ` separator when it is short: `// swiftlint:disable:this rule - fixture data`.
  A reader must not have to guess.
- **Prefer the baseline for a sweep**, where dozens of sites fail one rule at once and the config
  header already explains them. Prefer an inline disable for a handful, because the reason then
  sits where the next reader is.
- **A signature we do not own is a permanent case.** `UIApplicationDelegate`'s
  `didFinishLaunchingWithOptions` takes an optional dictionary and nothing can change it, so its
  suppression will never be removed. Say so in the reason, so nobody spends time trying.
- **`no_magic_numbers` has two more permanent cases**, ruled by Paul 2026-10-23:
  - **A block of numbers that a token set or a spec defines** takes a `disable` and `enable` pair
    inside it, the one region allowed. A token (`Spacing(8)`) or a spec value
    (`HTTPStatus(code: 404)`) is where a number gets its name, and the rule flags a literal inside
    a call even there. A `switch` over ranges a spec fixes, such as the HTTP status classes, is the
    same case.
  - **Test fixture data** takes `disable:this` with the reason "fixture data", because a fixture
    is data, not magic. Name the number instead when a name adds meaning, such as a phone width.

## Previews

Guard a `#Preview` with `#if DEBUG` **only** when it references a DEBUG-only symbol. Previews are
stripped from the shipped binary but still type-checked and compiled in release, so a bare
preview touching `Profile.preview` (DEBUG-only fixture) breaks the release build. Preview-only
helper code (fixtures, stub conformances) always needs its own guard; the macro does not enclose
it. Quick test before removing a guard, from the repository root:

```bash
swift build -c release \
  --package-path Packages/<Folder>/<Name> \
  --scratch-path "$(git rev-parse --show-toplevel)/.build-shared"
```

`--scratch-path` is not optional. Without it the build writes `Packages/<Folder>/<Name>/.build`, a full
copy of every dependency, and a hook denies the command.
