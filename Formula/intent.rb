class Intent < Formula
  RELEASE_VERSION = "3.2.8".freeze
  SOURCE_COMMIT = "b14e2745632d1c60963abe2c91527eac615c201f".freeze

  desc "Steel thread process for helping LLMs help you work with your code"
  homepage "https://github.com/matthewsinclair/intent"
  # THE URL IS AT TOP LEVEL, NOT INSIDE `on_macos do on_arm do`. Until 3.0.1 it
  # was nested there, and `brew tap` validates a tap's formulae under EVERY
  # simulated OS and arch: on Linux and on Intel the nested form has no url, so
  # the tap refused with "formula requires at least a URL" and "invalid syntax
  # in tap", for everyone.
  # It is macOS arm64's, and on Linux the package for the machine's
  # architecture overrides it inside `on_linux`, below.
  # There is no `version` line because brew reads it from the /v<version>/ path,
  # and `brew audit --strict` refuses the redundant one.
  url "https://github.com/matthewsinclair/intent/releases/download/v#{RELEASE_VERSION}/intent-aarch64-apple-darwin"
  sha256 "b02e9fad57b11fad6d0098669bb2280ed90536a9175b68208ec029880e49b13e"
  license "MIT"

  # On macOS it is arm64 only, by ruling (hv, 2026-08-15) rather than by
  # omission, and TRUE BY CONSTRUCTION through the dependency line inside
  # `on_macos`, which is what a platform limit in a formula is for. Both macOS
  # binaries are Developer ID signed and notarised; nothing is stapled, because a
  # bare Mach-O has nowhere to hold a ticket and Gatekeeper checks online. On
  # Linux (hv, 2026-10-14) the package for the machine's architecture carries
  # both binaries, built static against musl, and the support tree. (No comment
  # line here may open with the dependency keyword: `brew audit` reads that as a
  # commented-out dependency and refuses it.)
  on_macos do
    depends_on arch: :arm64

    resource "intentd" do
      url "https://github.com/matthewsinclair/intent/releases/download/v#{RELEASE_VERSION}/intentd-aarch64-apple-darwin"
      sha256 "9a6bc47b6a5da4edc3938ba7f506057d502be80924dc4e0599035be93ced4787"
    end

    # The support tree the binaries read and exec: templates, hooks, guards, the
    # rule library, skills and subagents. Not signed and not notarised -- there
    # is no Mach-O in it. See SUPPORT_PATHS in bin/.devbin/cmd/shared/support.lib.
    resource "support" do
      url "https://github.com/matthewsinclair/intent/releases/download/v#{RELEASE_VERSION}/intent-support.tar.gz"
      sha256 "15aeb28cf89121dbb11dd6c9859b7836766ea3164d0dd4cce4a56eb45bb603e7"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/matthewsinclair/intent/releases/download/v#{RELEASE_VERSION}/intent-x86_64-unknown-linux-musl.tar.gz"
      sha256 "b8e38f72bf6c3df1957f8098ec9d345f292fe71260383e489faa13f086771edc"
    end
    on_arm do
      url "https://github.com/matthewsinclair/intent/releases/download/v#{RELEASE_VERSION}/intent-aarch64-unknown-linux-musl.tar.gz"
      sha256 "ccca3770ebef96b9a5d9627bc29e0d15ca8414d613dfcc6869244d172ca07ade"
    end
  end

  # EVERYTHING LANDS IN libexec AND bin GETS SYMLINKS, which is not the obvious
  # layout and is not a style preference.
  #
  # `intent` locates its own install by walking up from its symlink-resolved
  # location to the directory containing `lib/templates/`, so the support tree
  # has to sit beside the binary inside the keg -- a plain `bin.install` leaves
  # the binary unable to find the hooks it execs, and both whiteboard guards and
  # every session hook stop working with nothing reporting a failure.
  #
  # That rules IN the layouts that keep the tree in the keg, and Homebrew rules one of them OUT. Installing to
  # `prefix/lib/templates` resolves correctly, but `lib` is a LINKED directory:
  # brew symlinks keg `lib` subdirectories into the shared prefix, so this would
  # publish a directory called `templates` into `#{HOMEBREW_PREFIX}/lib`
  # alongside every other formula's entries. `templates` is about as generic as a
  # name gets, and the collision would surface as a `brew link` failure in
  # somebody else's install. `libexec` is not linked, so the tree stays private
  # to this keg.
  def install
    if OS.mac?
      (libexec/"bin").install Dir["intent-*"].first => "intent"
      resource("intentd").stage do
        (libexec/"bin").install Dir["intentd-*"].first => "intentd"
      end
      # The archive is rooted at the install root, so this stays correct when the
      # shipped set grows -- it installs whatever the tarball carries rather than
      # naming `templates` and having to change when something joins it.
      resource("support").stage do
        libexec.install Dir["*"]
      end
    else
      # The Linux package is the install root already, under the one top-level
      # directory brew strips when it unpacks: bin/intent and bin/intentd, and
      # the support tree beside them (bin/int linux package).
      libexec.install Dir["*"]
    end

    # THE EXECUTABLE BIT, AND IT IS NOT BELT-AND-BRACES -- WITHOUT IT THE KEG
    # INSTALLS AND NOTHING IN IT RUNS. GitHub serves release assets as plain
    # files with no exec bit, and Homebrew's `.install` PRESERVES the source
    # mode rather than setting one. So 644 goes in, 644 comes out, `brew
    # install` prints its beer emoji, and every `intent` call returns
    # `permission denied`. Measured on the v3.0.0 tap, 2026-08-26, on the first
    # real install from the network. Harmless on Linux, where tar keeps the mode.
    #
    # A CACHE-PRESEEDED INSTALL CANNOT CATCH THIS, which is why it survived
    # every proof taken before that one: a preseed fills the cache from LOCAL
    # files that are already +x, so the mode survives and the install works.
    # Only the network hop loses it. "Proves everything but the network hop"
    # was an honest scoping, and this is what was behind it.
    chmod 0755, libexec/"bin/intent"
    chmod 0755, libexec/"bin/intentd"

    bin.install_symlink libexec/"bin/intent"
    bin.install_symlink libexec/"bin/intentd"

    # THE MANIFEST (ST0087 T3), WRITTEN HERE BECAUSE THE KEG HAS NO CHECKOUT.
    # `intent install --managed-by brew` writes the same file for a tree it
    # publishes, and it runs only in a dev checkout, so the formula writes it
    # itself over what it laid out: the header, then one `shasum -a 256 -c` line
    # per file, every regular file under libexec, sorted bytewise. T3 fixes the
    # form and not the writer. `managed_by: brew` is what makes `intent doctor`
    # and `intent use` read this keg as the brew tree and refuse to write into it.
    # It is the end of `install` and not a post_install, because Homebrew 7's
    # `brew style` refuses post_install for the declarative post_install_steps,
    # which have no step that can hash a file. The binaries are prebuilt, signed
    # and static, so nothing brew does after `install` rewrites them, and doctor
    # names any listed file that changed or went missing since.
    manifest = libexec/".intent-install"
    files = Dir.glob("**/*", File::FNM_DOTMATCH, base: libexec).select do |f|
      (libexec/f).file? && libexec/f != manifest
    end
    lines = [
      "# tool: intent",
      "# version: #{RELEASE_VERSION}",
      "# source_commit: #{SOURCE_COMMIT}",
      "# managed_by: brew",
    ]
    lines += files.sort.map { |f| "#{(libexec/f).sha256}  #{f}" }
    manifest.write("#{lines.join("\n")}\n")
  end

  # A CAVEAT, NOT A post_install, AND THE CHOICE WAS DRIVEN (dc, 2026-09-11).
  # The pre-commit gate a project installs finds this keg through ~/.local/share/intent/home,
  # and only `intent bootstrap` writes that file, so a fresh install refuses
  # every commit until it runs. A post_install cannot run it for the user:
  # Homebrew gives post_install a throwaway HOME inside its sandbox and denies
  # writes outside the keg, measured with a probe formula (Dir.home was a
  # sandbox temp directory; a write to the real home failed with EPERM). The
  # caveat is conditional because bootstrap REPOINTS an existing pointer, and a
  # machine already set up -- a source checkout, say -- should not be moved.
  #
  # THE UPGRADE CASE (issue 0527, 2026-09-23). Intent 3.2.0 and earlier recorded
  # the versioned keg, Cellar/intent/<version>/libexec, and `brew upgrade`
  # deletes that keg, so the pointer names nothing and every gated commit is
  # refused. From 3.2.1, bootstrap records opt/intent/libexec, which follows
  # every upgrade. No 3.2.1 code runs before the old pointer breaks, so this
  # caveat is the one lever that reaches such a machine at its upgrade. It stays
  # conditional: a pointer naming anything else is left as it is.
  #
  # **WHETHER THE KEG IS STILL ON DISK DOES NOT DECIDE IT** (issue 0540). This
  # said to run bootstrap only once the keg the pointer named was gone, and a
  # keg brew has not cleaned up yet still resolves, so that machine read the
  # advice as not its own and broke at the next `brew cleanup`. A pointer
  # naming any keg under Cellar/intent/ is re-recorded, and `intent bootstrap
  # --check` (issue 0533) is how a reader sees which case they are in.
  def caveats
    <<~EOS
      Intent's pre-commit gate finds this install through ~/.local/share/intent/home, which
      only `intent bootstrap` writes, and `intent bootstrap --check` says where it points.
      Run
        intent bootstrap
      if that file does not exist yet, or if it names an Intent under Cellar/intent/, whether
      or not that version is still installed: Intent 3.2.0 and earlier recorded the versioned
      keg, which `brew upgrade` removes, and from then on every commit in a project with the
      gate installed is refused. Later versions record a path that survives upgrades, and a
      file naming anything else, such as a source checkout, needs nothing.

      A maintainer with a dev or opt tree beside this keg chooses which one answers
      `intent` with `intent use`, and `intent use brew` hands it back to this keg.
    EOS
  end

  # THE SERVICE BLOCK, ADDED 2026-09-05 (dc) BECAUSE ITS OWN STATED PRECONDITION
  # WAS MET. This comment read: no start verb and no log path, so any block here
  # would be a guess at an interface that does not exist. Both halves are now
  # false and were driven on the delivered pair rather than inferred --
  # `intent daemon start|stop|status|run` all answer, start is idempotent and
  # reports its pid, and the log path exists and is being written.
  #
  # IT RUNS `intentd` DIRECTLY RATHER THAN `intent daemon run`, on the daemon's
  # own words: main.rs says serving is what this binary does with NO arguments,
  # and that `intent daemon run` EXECS this binary. Going through the CLI would
  # add a process for launchd to supervise in front of the one that matters, and
  # supervise the wrong one if the exec ever became a spawn.
  #
  # THE LOG PATHS ARE BREW'S, NOT THE DAEMON'S, AND THAT IS NOT A DUPLICATE.
  # intentd writes its own structured log under the user's state dir; these
  # capture stdout and stderr, both into one brew log, where main.rs puts the
  # warnings a supervised process would otherwise drop on the floor. The brew log
  # and the daemon's log are different files with different subjects. On Linux
  # `brew services` runs it under systemd's user manager, which no run has
  # proven yet.
  service do
    run [opt_bin/"intentd"]
    keep_alive true
    log_path var/"log/intentd.log"
    error_log_path var/"log/intentd.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/intent --version")
  end
end
