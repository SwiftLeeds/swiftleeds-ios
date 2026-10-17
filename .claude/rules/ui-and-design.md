---
paths:
  - "**/UIDesign/**"
  - "**/*UI/**"
  - "**/*View.swift"
  - "**/*Screen.swift"
  - "**/*Style.swift"
  - "SwiftLeeds/**"
---

# UI rules for this repo

Apple's own guidance, gathered 2026-09-25 and approved the same day.

**Why these live here and not in a skill.** Every skill named below is vendored from GitHub by the
skill manager and pinned by content hash in `skills-lock.json`. An edit to one would be overwritten
on the next sync. So the rule lives here and names the skill it extends.

The path globs above are a rough net. The real trigger is any turn that plans, designs, reviews or
writes SwiftUI, a view, a style, a component or a screen. A token, a color and an icon count.

## Color must survive being taken away

Extends `ios-accessibility`.

- **Two Apple surfaces repaint your content in one color.** Complications in tinted mode, and
  widgets in accented rendering mode. Neither asks first.
- **Apple states the rule outright**, on the Complications page: "Avoid using color as the only way
  to communicate important information. You want people to get the same information in tinted mode
  as they do in nontinted mode."
- **So a status carries a symbol or a word as well as a tint.** Never the tint alone.
- **The check**: render the component in greyscale and ask whether it still says the same thing. If
  it does not, the color was doing work nothing else was.
- **Every UI change that uses color for meaning gets greyscale captures**, with "Differentiate
  Without Color" turned on, before it is called done. Decided 2026-10-14. Turn the setting on with
  `xcrun simctl spawn <id> defaults write com.apple.Accessibility DifferentiateWithoutColor -bool true`
  and relaunch the app. Convert a capture with
  `sips --matchTo '/System/Library/ColorSync/Profiles/Generic Gray Profile.icc' <in> --out <out>`.
  Both verified on iOS 27.0, 2026-10-14.
- **A gradient does not survive either.** Accented rendering tints content to a single color, so a
  two-stop fill flattens to one.
- Two places this already bites: `StatusColor` carries meaning in color, and the role badge takes
  the role's gradient.

## Decorative content does not scale with the text size

Extends `ios-design-guidelines` and `swiftui-style-driven-components`.

- **Essential content scales. Decoration does not.** Apple: "apps should prioritize scaling
  essential content over decorative views."
- **An SF Symbol scales on its own.** No work needed.
- **An asset scales through `@ScaledMetric`**, by naming its width or height.
- **Some control heights must not scale at all.** Apple's example is the tab bar: "If the tab bar
  height were to increase when large text is enabled, it would occupy almost a quarter of the
  screen."
- **So decide which one a component is, and say so in its doc comment.** A photo of a speaker is
  essential. A background flourish is not.
- Open question, not yet answered: `Avatar` grows to 1.75 times its size with the text size.

## Switch the axis at accessibility sizes

Extends `swiftui-style-driven-components`.

- **Use `AnyLayout` over `HStackLayout` and `VStackLayout`.** One view hierarchy, two arrangements.
  Not an `if` around two copies of the content.
- **Key it on `dynamicTypeSize.isAccessibilitySize`**, not on a specific size.
- **The stated aim is to give text more width**, which is what tells you which way to switch.
- **Let text take as many lines as it needs** rather than clamping it. Apple's wording is about
  `UILabel` and `numberOfLines = 0`, and the point carries.
- **Vertical growth is correct behavior**, not a defect. A row that becomes two lines at an
  accessibility size has done the right thing.

## Glass cannot sample glass

Extends `swiftui-liquid-glass`.

- **Adjacent glass elements must share one `GlassEffectContainer`.** Apple: "This grouping is
  essential for visual correctness."
- **The reason is optical, not stylistic.** "Glass can not sample other glass, so having nearby
  glass elements in different containers will result in inconsistent behavior."
- **The material samples beyond its own bounds**, "from an area larger than itself", which is why
  two separate containers disagree.
- **`glassEffectID` plus a namespace** gives the morph between a collapsed and an expanded group.
- **Tint must mean something.** Apple: "only use this to convey meaning and not just for visual
  effect."

## Chrome may carry glass. Content may not

Extends `swiftui-liquid-glass`. Decided 2026-09-25, correcting how the earlier rule was applied.

- **The rule was always about content.** "No glass in scrolling content" does not mean a toolbar item
  avoids glass. A toolbar item is chrome, and on iOS 26 the system gives it a glass background by
  default.
- **An avatar in a toolbar keeps its glass.** Slack ships this, shown at WWDC: the profile avatar
  sits in the top bar's capsule beside a second control.
- **So reach for `.sharedBackgroundVisibility(.hidden)` only with a reason you can state.** It
  removes something the system drew on purpose.
- **The shape follows the count**: one item is a circle of glass, two or more grouped items share one
  capsule.

## An image inside a line of text

- **`Text` interpolates an `Image`**, and the image sits on the baseline and wraps with the line.
  `Text("32 min \(Image(systemName: "captions.bubble")) CC")`. Typechecked 2026-09-25.
- **Reach for it when marks must wrap.** An `HStack` of badges does not wrap, so a long metadata row
  overflows instead of flowing onto a second line.
- **The trap, measured with a control**: interpolating any other view still compiles. `Circle()` in a
  `Text` raises only a deprecation warning and renders the value's debug description. The wrong type
  is not a build error, so it reaches the screen.
- **VoiceOver reads the whole line as one label.** An interpolated image contributes no label of its
  own, so put the meaning in the string or give the line an `accessibilityLabel`.

## Inset a scroll view with contentMargins, not the safe area

Extends `swiftui-patterns`.

- **The safe area cannot inset content and indicators separately.** Apple: "A ScrollView resolves
  the safe area into the margins it applies to its content... it's not possible to configure
  different insets for different kinds of content by modifying the safe area."
- **`contentMargins` can.** It insets the content separately from the scroll indicators, or the
  other way round.
- **Not every modifier is legal inside `scrollTransition`.** "Customizing the font is not supported
  and will not build. Anything that will change the overall content size of the ScrollView cannot be
  used."
- **A `ScrollView` evaluates its content eagerly** unless a lazy stack changes that.

## containerRelativeFrame replaces GeometryReader

Confirms `swiftui-design-skill`, which already bans `GeometryReader`. This is the source.

- **Size against the container with `containerRelativeFrame`.** Apple: "Previously you would've had
  to use a GeometryReader to accomplish this, but this year SwiftUI makes this much easier."
- **It takes a count and a spacing** to build a grid-like layout without arithmetic.

## Never build a custom text field

No skill owns this. New rule.

- **A framework text view hands you work you would otherwise write.** Apple's own list: "Text input,
  selection, accessibility, undo and redo, dictation, inline predictions, and more."
- **A custom one gives all of that back.** "You get total control over the storage, layout, and the
  viewport layout process, but you give up everything that the framework text views provide."
  Apple adds that building one to production quality "is a lot of work".
- **So wrap `UITextView` in a representable** when SwiftUI's `TextEditor` is not enough. Do not
  start from `NSTextLayoutManager`.
- **Reading `textView.layoutManager` silently drops the view to TextKit 1**, which turns off Natural
  Selection for mixed left-to-right and right-to-left text. Use `textView.textLayoutManager`.

## Right-to-left is supported, and icons flip with it

Extends `ios-design-guidelines`. Decided 2026-10-15, after `arrow.up.right` kept pointing up-right
in an Arabic capture of the person page.

- **Every screen works in a right-to-left language.** Layout mirrors on its own; a directional
  symbol does not, unless the symbol is one Apple marks as mirroring.
- **Name the direction, not the side.** SF Symbols with `forward` and `backward` in the name flip
  with the layout direction: `arrow.up.forward`, `arrow.forward`, `chevron.forward`. Symbols
  with `right` and `left` never flip. A mark that means "onward" or "leaves the app" takes the
  `forward` name.
- **Capture right-to-left** for any view with a directional mark, with the launch argument
  `-AppleLanguages (ar)`, and open the image.
- Known offender: `Icon.openExternal` in `UIDesign` is `arrow.up.right.square`. Not yet fixed.

## A line or a stroke is 2pt or more

Extends `ios-design-guidelines`.

- **Apple's floor for a drawn line is two points.** "Generally use line widths of two points or
  greater. Thinner lines can be difficult to see at a glance, especially when the wearer is in
  motion."
- Stated for complications, so the reader is small and moving. Treat it as the floor wherever a
  stroke has to be read rather than felt.
- A hairline separator is a different thing. It is a system-drawn edge, not a mark carrying meaning.
