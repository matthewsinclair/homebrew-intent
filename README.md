# homebrew-intent

The [Homebrew](https://brew.sh) tap for **[Intent](https://github.com/matthewsinclair/intent)** -- a steel thread process for helping LLMs help you work with your code.

```sh
brew tap matthewsinclair/intent
brew install intent
```

## Status: no formula yet

**This tap is empty on purpose.** Intent v3 is the first release to ship a compiled binary, and it has not been cut yet. A formula pointing at a release that does not exist would let `brew tap` succeed and `brew install` fail with a download error -- which reads as "the tap is broken" rather than "the release is not out yet". An empty tap says the true thing.

The formula lands here with the first v3 release. Until then, install Intent [from source](https://github.com/matthewsinclair/intent).

## What lands here

Two binaries, from one formula:

| Binary    | What it is                                                                       |
| --------- | -------------------------------------------------------------------------------- |
| `intent`  | The CLI. Steel threads, work packages, acceptance criteria, project scaffolding. |
| `intentd` | The daemon. One per machine; the CLI talks to it over GraphQL.                   |

`intentd` installs as a formula resource alongside the CLI, so `brew install intent` gets you both.

## Platform support

**macOS arm64 (Apple Silicon) only, for now.** That is a deliberate first-cut decision rather than an oversight, and it is not permanent -- Linux binaries need no code signature, so adding them is purely additive whenever there is demand. If you want Intent on Linux or an Intel Mac today, build [from source](https://github.com/matthewsinclair/intent); it is a normal Rust workspace.

## Signing and notarisation

Both binaries are **Developer ID signed and notarised by Apple** (Geodica Pty Ltd, team `76BQL8L47U`). Every release is verified from a quarantined copy before its checksums are published, so a Gatekeeper prompt should never appear.

If you are wondering why `stapler validate` reports no ticket: a bare Mach-O executable has nowhere to hold one. Stapling applies to `.app` bundles, `.pkg` and `.dmg` files. For a standalone binary the notarisation ticket lives on Apple's servers and Gatekeeper checks it online. **No ticket on the file is the correct steady state here, not a missing step.**

## The formula is generated -- please do not hand-edit it

When a formula does appear in `Formula/`, it is emitted by `int macos formula` in the Intent repository, from artefacts that have already been proven signed and notarised. Its version and every `sha256` are read from the built binaries themselves, never typed.

That matters because of an asymmetry that is easy to get backwards: **signing rewrites the binary in place, while notarisation leaves it byte-identical.** A checksum taken one step too early does not fail for the person cutting the release -- it fails for everyone running `brew install`, against a formula already published, and Homebrew reports it as a corrupt download. Generating the formula removes the hand-copied number that failure depends on.

So a hand-edit here will be silently overwritten at the next release, and worse, a hand-corrected hash would paper over a real problem upstream. If a checksum looks wrong, that is a bug worth [reporting](https://github.com/matthewsinclair/intent/issues).

## Licence

Intent is MIT licensed. See the [main repository](https://github.com/matthewsinclair/intent).

(C) hello@matthewsinclair.com
