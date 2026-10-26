---
paths:
  - "**/Tests/**"
  - "**/*Tests.swift"
  - "**/*Test.swift"
---

# Testing in this repo

This file holds the repo-specific testing idioms. Compiled 2026-08-22.

## The message grid (Sandi Metz, "The Magic Tricks of Testing")

- Incoming query: assert the returned value.
- Incoming command: assert the direct public side effect.
- Messages to self / private methods: do not test. Wanting to is a design signal.
- Outgoing query: do not test or mock; it is another object's incoming message.
- Outgoing command: assert only that it is **sent**, via a double; never its result.
- Test each thing once, in the proper place.

Record every call in a spy, but **assert `Action`s only for outgoing commands** that are pinned
contracts (`set`/`remove` with the durable key). Assert a query (`current`) by its returned value.

## swift-dependencies idiom

Inject collaborators with `withDependencies { $0.x = spy } operation: { let sut = Client.live;
try await sut(...) }`. Construct **and** exercise the sut inside the operation, so the overrides
are in scope. Override only what the test cares about; other `liveValue`s resolve themselves.

## A suite that relies on per-test dependency state links `DependenciesTestSupport`

A test that reads `@Shared(...)` or `@Dependency(\.defaultAppStorage)` without overriding it relies
on swift-dependencies giving each test its own `testValue`. In release that only works when the
test target links `DependenciesTestSupport` **and** a source file references it: the lookup is by
`dlsym`, so an unreferenced module can be dropped. Write `import DependenciesTestSupport` and
`@Suite(.dependencies)` on the suite, as `SelectedThemeTests` does. The trait may sit on a test
instead, as `SettingsViewModelTests` has it on two tests.
Found 2026-10-06: two of three `ColorTheme` (now `UITheme`) theme tests failed under `swift test -c release` with
the manifest line absent. CI runs the package tests in both configurations since
`ci/release-package-tests`.

## Swift Testing mechanics

- `#expect` does not handle a thrown error from its expression. Pull the `try await` call into a
  `let` first, then `#expect(value == expected)`. For expected failures:
  `await #expect(throws: SomeError.case) { try await ... }`.
- In tests, prefer `try #require(...)` over any force operation; it fails one test with a clear
  message instead of crashing the run.
- **CoreFoundation bridging:** `as? CFString` is rejected by the compiler ("conditional downcast
  ... will always succeed"), so compare keychain constants as `String`:
  `dict[k] as? String == kSecClassGenericPassword as String`. Third-party code force unwraps in
  tests (`keychain-swift` does); do not copy it.

## Look at every image the run records or changes

**A passing snapshot suite proves the pixels did not move. It does not prove they were ever
right.** Open each image the run writes, with the `Read` tool, and judge it. A recorded image is
the only evidence of what the code actually draws.

- **Every image, not a sample.** The ones skipped are where the defect hides: a variant at the
  largest accessibility size, the narrowest width, dark mode.
- **Compare against the intent**, not against the last run. "It matches the reference" is the
  test's job, not yours.
- **An image that carries no information is a finding**, not a pass. A fixed-size view rendered
  at a width it ignores costs a reviewer's time and tells them nothing.

**A compact check asks what the smallest screen would really show.** It is not "does this view
adapt to width". Give it a composition that screen would actually use, not a row of samples laid
out for a reviewer. A view wider than the frame is centered and cropped at both ends, which hides
the very thing the check is for. Decided 2026-09-23.

**What a compact check should look for is still open**, and is being researched from Apple's own
watchOS guidance.

Found 2026-09-23, on `Avatar`: looking at the images caught content spilling out of a small
avatar, a status symbol off center in its disc, and two marks too small to read. Reasoning about
the code caught none of them. The same session skipped the compact variants, and that is where
the next finding was.

## A component that can be redacted needs a redacted snapshot

`.redacted(reason: .placeholder)` is how a loading state is drawn here, and it fails in ways no
other variant shows:

- **It ignores a clip shape.** A symbol or a word inside a circle redacts to a rounded rectangle
  that sits inside the circle rather than filling it.
- **Empty text has zero width.** A skeleton built from empty strings draws no bars at all, so the
  image is a row of circles and nothing else.
- **It does not animate.** There is no shimmer to distract from a wrong shape.

Measured 2026-09-24 on `Avatar`: the person symbol and the initials each drew a square inside the
avatar's circle. Reading the code caught neither. One image caught both.

**So a component's snapshot suite covers redaction as a variant, beside light, dark and the text
sizes.** Render the real component with sample content and `.redacted(reason: .placeholder)`, and
render it once per style it ships: a style's padding and font change the skeleton's shape, so one
image does not stand in for the others.

**A loading state is the component itself, redacted.** Do not build a placeholder component to
snapshot instead.

## Snapshot tests live in their own target

Decided 2026-08-28. Snapshot tests are behind `#if os(iOS)`, so the macOS CI job cannot see them.
They get a separate iOS Simulator job, and that job must stay cheap.

Since 2026-10-25 one other iOS-only test shares the snapshot target: UIDesign's
`ColorFamilyContrastTests`, which needs iOS traits to resolve Increase Contrast. A test like it goes
in the package's snapshot target too, because that is the only target CI runs on iOS.

**Three things make a package's snapshot tests run.** All three, or they silently never run:

1. A test target whose name ends `SnapshotTests`, for example `AuthenticationUISnapshotTests`.
   CI finds it with `swift package describe --type json`, so nothing else registers it.
2. A shared scheme of **the same name**, at
   `Packages/<Folder>/<Name>/.swiftpm/xcode/xcshareddata/xcschemes/<Target>.xcscheme`, holding only that
   target. Committed package schemes work; xcodebuild lists them.
3. `#if os(iOS)` around each file, so the target compiles to nothing on macOS.

**The scheme is the point, not a formality.** `-only-testing:` filters what runs, not what builds,
so without a one-target scheme xcodebuild compiles the package's other test targets anyway. That
compilation is the whole cost: measured on CI, the old job spent 6m48s to run 6.99s of tests.

**Pin the scheme's test language: `language = "en-GB"` and `region = "GB"` on its `TestAction`.**
Hyphenation follows the test run's language, so at accessibility text sizes a long word breaks
differently in US and British English. CI runners are US English, and a British-English Mac and
its simulators differ from them, so `ScheduleUI`'s references passed locally and failed ten images
on CI. Measured 2026-09-16, PR #172. `language = "en"` is not enough; `\.locale` in the view has no
effect. To reproduce CI locally, set a simulator's `AppleLanguages` to `en-US`.

Adding a suite to an existing snapshot target needs no action anywhere. A new package needs items
1 to 3. A file that calls `assertSnapshots` from any other target fails the lint job.

Numbers, for judging whether a future change helped: splitting the target took the iOS job from
**6m48s to 3m22s**, and the PR critical path from 6m48s to 3m48s, which is now set by
`Build SwiftLeeds`. Further gains have to come from that job, not this one.

## No `@testable import`, and the ladder

Import the module normally so only the public API is reachable. When a test seems to need
`@testable`, that is a design signal, not a licence. Worked example: `CorrelationTokenTests`
reached into an internal type; the fix was deleting the suite and asserting the same properties
through the public seam. Coverage went up. Reach for `package` before `public`: same-package test
targets see a `package` symbol without `@testable`. Never widen to `public` just to test.

Four pre-existing `@testable` uses remain, and are to be removed.

## Unit versus integration, the worked example

A suite is **integration** when it drives a composed `liveValue` or `.live` chain with only the
outer boundary stubbed; **unit** when the SUT is one type with collaborators supplied by the
test. The distinction lives in the **name** (`...IntegrationTests`), not the folder, because
folders mirror the source layout. `AttendeeRepositoryLiveTests` became
`AttendeeRepositoryIntegrationTests` for this reason: every test drove `liveValue` with only the
transport stubbed.

**No `sut` is the tell** that a suite is not testing what its name claims.
`AttendeeMapperLoggingTests` never declared one and drove the repository instead; the cause was
an `internal` mapper the test could not name, and the fix was `package`, not a broader test.

**Keep exactly one integration test for composition.** When a decorator is unit tested directly,
one integration test asserts the live chain still includes it. Probe it: removing the decorator
from `liveValue` should fail that test and nothing else.

**Stub the port you depend on, not the framework beneath it.** Only the adapter's own tests stub
`URLProtocol`: `HTTPClientURLSessionTests` is the one suite that may. Everything that takes an
`HTTPClient` is tested with `HTTPClientSpy` or `HTTPClient.responding(with:statusCode:)` from
`NetworkKitTestSupport`. A composed chain takes its transport as an `HTTPClient`, so the
composition root picks the adapter, as `SwiftLeedsApp` does for `authHTTPClient`.

## Spies, the detail

- The `Action` enum spy is an `actor`; a `nonisolated var` builds the closure-struct port, each
  closure recording its `Action` then running default behaviour (an in-memory `stored: Data?`
  for reads).
- **Opaque parameters** (an encoded DTO blob) make full `Action` equality impossible. Before
  adding a projection (`actions.map(\.key)`), check the assertion is needed at all: a round-trip
  usually pins key agreement, and a sibling command with no opaque payload pins the literal key.
- **Overridable behaviour**: give a function an overridable closure defaulting to the in-memory
  behaviour only when a test needs it. If settable closures fight actor isolation, back the spy
  with `LockIsolated` or a locked `final class` instead.
- For a thin adapter over a port, keep exactly one narrow round-trip to cover the mapping's
  symmetry; it legitimately goes through the spy when the persisted format is deliberately
  private (`CachedSession` is `internal`).

## Fixtures, the repo shape

A throwing getter keeps a fallible fixture reading as a value:

```swift
extension Credential {
    static var fixture: Credential {
        get throws { try Credential(emailAddress: EmailAddress("…"), ticketReference: TicketReference("…")) }
    }
}
```

Do not name a fixture for a guarantee the type already makes: `Credential.valid` was wrong,
because parse-don't-validate means an invalid one cannot exist. Randomised fixtures are under
evaluation.

## Driving the simulator UI

To tap through a screen, hand the work to the `simulator` agent (RocketSim, on an iOS 26 runtime) or
the `xcode-device` agent (Xcode's Device Hub). The `driving-the-simulator` skill holds
the Device Hub steps. A check that ends in "then open the Sponsors tab" is fine to plan on those
routes.

If neither agent can run, for example because no suitable runtime is installed, either move the code
into a package where a test can reach it, or say plainly in the PR that the screen is unverified
and needs a human.

History, for anyone who meets the old routes. Before the agents existed, two routes to driving the
UI failed on the machine where this was measured (2026-09-11):

- **`idb` was not installed**, so every `ios-simulator-skill` script that reads the accessibility
  tree failed with `FileNotFoundError: 'idb'`. That covers `screen_mapper.py` and `navigator.py`.
- **AppleScript could not reach System Events** (`-1743`), so clicking a window by coordinate
  failed too.

What still worked: `simctl_boot.py`, `app_launcher.py` (install, launch, terminate, `--state`) and
`log_monitor.py`. They prove an app launches and stays running, and read its log, but they cannot
reach a screen that needs a tap.

`nm` and `strings` over the built app binary read zero for **every** package, including ones known
to be linked, so neither proves a package is linked. The compile is the proof: a missing product
fails the build.
