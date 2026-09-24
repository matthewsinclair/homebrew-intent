# homebrew-intent

The [Homebrew](https://brew.sh) tap for **[Intent](https://github.com/matthewsinclair/intent)** -- a steel thread process for helping LLMs help you work with your code.

```sh
brew tap matthewsinclair/intent
brew install intent
```

Upgrade and removal are the ordinary verbs:

```sh
brew upgrade intent
brew uninstall intent
```

**This README does not name a version, on purpose.** `brew info intent` reports what the tap offers and what you have installed, and it reads them from the formula rather than from prose, so it cannot go stale the way prose does.

## What lands here

The formula installs these release assets:

| Asset                          | What it is                                                                                                                  |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| `intent-aarch64-apple-darwin`  | The CLI. Steel threads, work packages, acceptance criteria, project scaffolding.                                            |
| `intentd-aarch64-apple-darwin` | The daemon, one per machine, serving every project on it. Optional: see below.                                              |
| `intent-support.tar.gz`        | The templates, hooks, guards, rule library and skills the CLI reads and execs. No Mach-O in it, so nothing in it is signed. |

`brew install intent` gets you all of them: the daemon and the support tree install as formula resources alongside the CLI.

The release also carries `Intent.app.zip`, the Intent menubar app. **The formula does not install it**: download it from the [GitHub release](https://github.com/matthewsinclair/intent/releases), unzip it, and move `Intent.app` to `/Applications`.

### intentd is optional

**The CLI does not require the daemon.** Every `intent` command does its work in-process unless you pass `--daemon`, with two exceptions: `intent graphql` is answered only by a running `intentd`, and `intent browse` opens a page that a running `intentd` serves. To run `intentd`, use `intent daemon start` (and `status`, `stop`, `restart`), or let launchd keep it running:

```sh
brew services start intent
```

The formula's service block runs `intentd` directly and sends its stdout and stderr to `intentd.log` under Homebrew's `var/log`.

### Where it lands

Both binaries install into `libexec/bin` inside the keg, with symlinks from `bin`, and the support tree unpacks beside them in `libexec`. That is not the conventional `bin.install`, and the formula carries the full reasoning at the `def install` block -- briefly: `intent` finds its own hooks by walking up from its resolved location to the directory holding `lib/templates`, so the tree has to sit inside the keg beside the binary, and `libexec` is the one place Homebrew does not symlink into the shared prefix.

## Platform support

**macOS arm64 (Apple Silicon) only, for now.** That is a deliberate first-cut decision rather than an oversight, and it is not permanent -- Linux binaries need no code signature, so adding them is purely additive whenever there is demand. If you want Intent on Linux or an Intel Mac today, build [from source](https://github.com/matthewsinclair/intent); it is a normal Rust workspace.

## Signing and notarisation

Both binaries are **Developer ID signed and notarised by Apple** (Geodica Pty Ltd, team `76BQL8L47U`). Every release is verified from a quarantined copy before its checksums are published, so a Gatekeeper prompt should never appear.

If you are wondering why `stapler validate` reports no ticket: a bare Mach-O executable has nowhere to hold one. Stapling applies to `.app` bundles, `.pkg` and `.dmg` files. For a standalone binary the notarisation ticket lives on Apple's servers and Gatekeeper checks it online. **No ticket on the file is the correct steady state here, not a missing step.**

## The formula is generated -- please do not hand-edit it

`Formula/intent.rb` is emitted by `int macos formula` in the Intent repository, from artefacts that have already been proven signed and notarised. Its version and every `sha256` are read from the built binaries themselves, never typed.

That matters because of an asymmetry that is easy to get backwards: **signing rewrites the binary in place, while notarisation leaves it byte-identical.** A checksum taken one step too early does not fail for the person cutting the release -- it fails for everyone running `brew install`, against a formula already published, and Homebrew reports it as a corrupt download. Generating the formula removes the hand-copied number that failure depends on.

The same argument covers the `chmod` in the install block, and that one is not hypothetical. GitHub serves release assets with no executable bit and Homebrew's `.install` preserves the source mode, so the first published formula installed two binaries at mode 644: `brew install` succeeded, printed its beer emoji, and every `intent` call returned `permission denied`. **The fix went into the generator rather than into this file**, because a fix applied here is regenerated away at the next cut, and a green install would then be evidence of nothing.

So a hand-edit here will be silently overwritten at the next release, and worse, a hand-corrected hash would paper over a real problem upstream. If a checksum looks wrong, that is a bug worth [reporting](https://github.com/matthewsinclair/intent/issues).

## Licence

Intent is MIT licensed. See the [main repository](https://github.com/matthewsinclair/intent).

(C) hello@matthewsinclair.com
