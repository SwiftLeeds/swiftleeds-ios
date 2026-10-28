---
paths:
  - ".github/**"
  - "fastlane/**"
  - "Configuration/**"
---

# CI and release

Compiled 2026-08-22. Timings measured 2026-08-16/17 on real CI runs; verify against current
workflows before acting.

## Pin the runner image and the Xcode version

`.github/workflows/build.yml` pins `runs-on: xcode-27` and selects Xcode with
`maxim-lobanov/setup-xcode` (27.0). Moved from `macos-26` and 26.5 on 2026-10-12, branch
`ci/xcode-27`. GitHub now names macOS images by Xcode version, so no `macos-27` label exists. The
label does not fix the macOS version, and the image is a public preview, so `setup-xcode` is the
pin that fails legibly. The snapshot job also checks the exact runtime build (iOS 27.0, 24A434),
because the references were recorded on it. **Never reintroduce `macos-latest` or a hardcoded
`DEVELOPER_DIR` path.** An image roll must not be able to break every branch at once with no
commit to blame; `setup-xcode` fails immediately and legibly when a version is absent, where a
bad `DEVELOPER_DIR` fails minutes in with a misleading error. (A `macos-latest` roll to the
`macos-26` image broke every branch for months; fixed in PR #106.)

**Keep local Xcode matching the CI pin.** Different Swift compilers judge code differently: a
`@Test(arguments:)` array with `-.infinity` compiled on 26.0.1 and was rejected on 26.5 as
ambiguous. When versions diverge, a local pass is weaker evidence; say so. Verify with
`xcodebuild -version`.

**Diagnose CI failures by age and spread before reading code.** Unrelated branches failing
identically at the same step, with the last green run months earlier, is an environment change,
not anyone's diff. Confirm with `git diff origin/main origin/<branch> -- .github/ fastlane/`
and `gh run view <id> --log | grep "Image Release"`. When `main` has not run in months, "main is
green" means nothing.

## Test speed: what is settled

**Every timing below was measured on the `macos-26` image with Xcode 26.5.** None has been
measured again on `xcode-27`. Treat each as a starting value there, not a settled one.

- **Shared scratch path** (`swift test --scratch-path "$PWD/.build-shared"`, PR #115) took the
  big win: test step 132s to 83s. **Superseded on CI by PR #193**, which tests two packages at
  once. SwiftPM locks a scratch path, so each lane has its own under `RUNNER_TEMP`, and a second
  path repeats 14% of the dependency compilation. One shared path is still right locally.
- **A package's compile does not use all 3 of the runner's cores.** Evidence, PR #193: the
  summed compile intervals nearly doubled, 178s to 346s across two lanes, and the step still
  fell from 311s to 254s. The two lanes used cores that one package left idle. That summed
  figure mixes duplicated work with contention, and this measurement cannot separate them.
- **Two lanes is the ceiling on this runner, measured** (PR #194). Three lanes lost all five
  paired samples against two: medians 285s against 238s, on one tree where only `LANE_COUNT`
  differed. The third lane compiles the shared dependencies a third time, and each `swift test`
  already asks for all 3 cores, so it buys contention rather than work.
- **Memory is not what stops a third lane.** The step prints how much memory the lanes compress
  and swap. Every run in both arms swapped out 0 MB, and the compression ranges overlap (3259 to
  3580 MB at three lanes, 2276 to 3583 MB at two), so memory did not separate them.
- **Which memory figure to read, and when.** Within one run, compression is the early signal:
  macOS compresses before it swaps, so a runner under pressure only looks slow. Between two runs,
  compare swap and not compression, because compression is a total over the window and a longer
  run compresses more for that reason alone.
- **Take five paired samples before believing a CI timing**, both arms on one tree where only the
  value under test differs. One sample each cannot see a 47s difference against this runner's
  spread. The two-lane arm alone has spanned 156s to 289s.
- **Five is enough to decide, not always enough to settle.** It settled the package lanes, where
  two lanes won 5 of 5. It did not settle the snapshot workers, where three won 4 of 5 with a gap
  of 23s to 37s inside a 142s spread (PR #195). **Before taking more samples, work out how many
  would be needed:** that case needed about 60 per arm, so the answer was to stop, not to measure
  harder.
- **Caching dependency sources was tried and rejected** (PR #117): a warm cache took as long as
  no cache, because runner network to GitHub is fast.
- **Actual test execution is under a second** (0.58s of a 131s job). "Speed up the tests" means
  "speed up compilation". A thousand more unit tests will barely move the number.
- **Measure the noise floor before optimising.** GitHub macOS runners vary by about 50% between
  runs; a change worth under about 30s cannot be measured here, and two samples prove nothing.

## The package tests run in Debug and Release

Added 2026-10-07, branch `ci/release-package-tests`. The `test-packages` job is a matrix of two
lanes with the same script: `Test Swift Packages` (Debug, the required check, name unchanged)
and `Test Swift Packages (Release)`. Release catches a test that uses a DEBUG-only symbol or
relies on DEBUG-only test isolation. The format check runs in the Debug lane only.

- **In release, swift-dependencies cannot tell which test is running unless
  `IssueReportingTestSupport` is linked and referenced.** `DependenciesTestSupport` links it. Without
  it, every test shares one cached `testValue` and one `@Shared` reference, so a suite that relies on
  implicit per-test state (`defaultAppStorage`, `@Shared`) leaks between tests. The lookup is by
  `dlsym`, so the module must be referenced from source, not only linked: `import
  DependenciesTestSupport` plus `@Suite(.dependencies)`.
- **In release, `reportIssue` only prints** unless the same module is linked. A test that relies on
  a reported issue to fail passes silently in the Release lane.
- **`LANE_COUNT: 2` was measured in Debug** and is unmeasured in Release.
- The release lane is the seventh macOS job on a five-runner account, so a run gets longer by
  about one queued job. Accepted 2026-10-06, including on pull requests.

## The 5 macOS runners are an account limit, not a per-run one

**Measured 2026-09-23.** Exactly 5 macOS jobs start at once and the 6th starts within seconds of
the first finishing. The workflow declared 7, so two always waited 3 to 4 minutes.

- **A run measured while another run is in flight measures the contention.** One measurement was
  thrown away when a second branch's run overlapped it for 6m12s and six jobs queued. Wait for a
  quiet account: `gh run list --json status`.
- **A run cannot be shorter than its longest job.** Removing the queue is worth about a minute at
  the median, and its value is removing the tail, not the minutes. Runs ranged 504s to 666s.
- **Six macOS jobs cannot beat about 600s however they are arranged**, because one slot must take
  two jobs and the two shortest sum to more than the longest. Serialising the two app builds was
  tried in PR #198 and made them the critical path at 620s, for a 25s gain.
- **`concurrency` with `cancel-in-progress` must exclude `main`.** Every push there shares one ref,
  so cancelling would let a second merge kill the first merge's run, and that run is the only thing
  that tests what a pull request's skip logic left out.

## Caching build products: deliberately not done

A restored cache from a different runner is an untested case whose failure mode is a green tick
over code that was never really rebuilt. **Revisit when the test step passes 3 to 4 minutes.**
If done then: the cache key must include the Xcode/Swift version (build products from one Xcode
are silently invalid for the next, for example 26.5 to 26.6) plus a hash of the `Package.resolved` files. For the build lanes,
the `clean` action in the `fastlane/Fastfile` lane's `xcodebuild` call blocks DerivedData caching and is the prerequisite to
remove first.

Options considered and rejected: a runner-per-package matrix (worst cost per second saved, 10x
billing); an umbrella package (ruled out, it couples the build graph against
bounded-context separation). Swift Testing already parallelises within a target.

The matrix billing reason is wrong for this repo: it is public, so macOS minutes are free. The
matrix is still parked, now as "see whether it is needed" (2026-09-21).

## The snapshot job (PR #176, 2026-09-21)

- **Superseded in part on 2026-09-22** (branch `ci/one-snapshot-call`): two or more targets now run
  in one `xcodebuild test` call against the `SnapshotTests` scheme in the app project, which holds
  every snapshot target. One target still runs through its own package scheme, because
  `-only-testing:` does not make the build smaller. Each call waited 23s to 45s on CI before its
  first test ran, which was 236s of a 554s job. A Linux lint check keeps the scheme in step with
  the targets.
- **Build every snapshot scheme through `SwiftLeeds.xcodeproj`, with one `-derivedDataPath`.**
  Run from its own folder, each package is a separate workspace, and Xcode rebuilds the shared
  dependencies for every one, even in a shared derived data folder. Checked by file times: the
  shared objects were rewritten by the second package. Through the project, the second package
  compiled 50 files, against 292 for the first. On CI, packages after the first dropped from
  about 2m30s to about 1 minute each.
- **A pull request runs only the snapshot targets it can affect.** `swift package
  show-dependencies` gives each package's local dependency closure; a package runs when any path
  in it changed. `.github/` or `SwiftLeeds.xcodeproj/` changes run all, and so does every push to
  `main`. This is the "real dependency map" an earlier rejection asked for.
- **Xcode 26 does not compile `swift-syntax`** for the macro packages. It is not in the derived
  data at all, so it is not the cost.
- **Two parallel testing workers, not three** (PR #195, 2026-09-23). Three won 4 of 5 paired runs,
  median 264s against 301s, but the gap sits inside the runner's own spread. Neither arm swapped,
  so memory is not the blocker; the measurement simply cannot size the gain.

## Build configuration facts

- Two apps, one target, four configurations, driven by `Configuration/*.xcconfig`. Three known
  configuration defects (verified 2026-08-15/16): `PRODUCT_NAME` in the xcconfig is ignored
  because every target sets `PRODUCT_NAME = "$(TARGET_NAME)"` in the project file, so both apps
  produce `SwiftLeeds.app`; the App Clip asset catalogs were duplicated in its Resources phase
  (fixed in PR #184); and `aps-environment` is `development` in both apps' entitlements, which
  Xcode rewrites on export, so confirm before a release.
- The Fastfile's one `build` lane runs `xcodebuild clean build`, unsigned and with no archive,
  because fastlane's `build_app` cannot read the JSON project format. So CI proves compilation only, in
  Release for each brand since 2026-10-06. Debug is not built on CI: the test jobs compile the
  packages in Debug and Release, the launch jobs compile the App Clip in Debug, and Debug then
  Release in one job measured 8m38s against 4m07s on the critical path (PR #218). Releases are
  manual (Xcode Archive, then Organizer upload). The planned direction is Fastlane on GitHub
  Actions, with both apps shipping together.
- `setup-xcode` is nearly free (~2s); the image ships the pinned Xcode.
- The `maintenance.lock` warnings in CI output are SwiftPM's own cache, not our code.

## Screenshotbot reviews the snapshot references (branch `ci/screenshotbot-upload`, 2026-10-15)

Git still owns the reference images and the simulator job still compares pixels. A Linux job,
`Upload Screenshots (Screenshotbot)`, uploads the committed images on every PR and every push to
`main`, one channel per package (`ios/<Package>`), batched into one PR status named
`ios-snapshot-tests`. Both the job and that status are required checks on `main`.

- **The recorder is pinned** by version and SHA-256 in `.github/scripts/install-recorder.sh`,
  because Screenshotbot's own install script downloads "current" with no checksum. Bumping the
  version means replacing every checksum in that script.
- **The job checks out the PR head SHA**, not the default merge commit, so the status lands on a
  commit the branch rule can see. It is the one checkout in `build.yml` that passes `ref:`.
- **A missing secret fails the job on purpose.** Only a fork PR skips, because it has no secrets.
  For a fork PR a maintainer pushes the commits to an org branch and merges that PR instead.
- **A failed upload on `main` is fixed by re-running the job.** Screenshotbot walks back to the
  nearest commit with a baseline after five minutes, so a gap costs a wait, not a broken chain.
- **Upload per test target folder, never per `__Snapshots__` folder.** `AuthenticationUI` nests
  three of them, and a folder search finds 7 packages of 8 and passes.
