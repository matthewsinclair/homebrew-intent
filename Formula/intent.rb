class Intent < Formula
  RELEASE_VERSION = "3.2.2".freeze

  desc "Steel thread process for helping LLMs help you work with your code"
  homepage "https://github.com/matthewsinclair/intent"
  # THE URL IS AT TOP LEVEL, NOT INSIDE `on_macos do on_arm do`. Until 3.0.1 it
  # was nested there, and `brew tap` validates a tap's formulae under EVERY
  # simulated OS and arch: on Linux and on Intel the nested form has no url, so
  # the tap refused with "formula requires at least a URL" and "invalid syntax
  # in tap", for everyone. There is no `version` line because brew reads it
  # from the /v<version>/ path, and `brew audit --strict` refuses the
  # redundant one.
  url "https://github.com/matthewsinclair/intent/releases/download/v#{RELEASE_VERSION}/intent-aarch64-apple-darwin"
  sha256 "1a80bb21bd6b241bdb66c8f0753cf62fe828b06def8e7fa06f65d3c0665d4682"
  license "MIT"

  # macOS arm64 only, by ruling (hv, 2026-08-15) rather than by omission, and
  # TRUE BY CONSTRUCTION through the dependency lines below, which is what
  # a platform limit in a formula is for. Both binaries are Developer ID signed
  # and notarised; nothing is stapled, because a bare Mach-O has nowhere to hold
  # a ticket and Gatekeeper checks online. (No comment line here may open with
  # the dependency keyword: `brew audit` reads that as a commented-out
  # dependency and refuses it.)
  depends_on arch: :arm64
  depends_on :macos

  resource "intentd" do
    url "https://github.com/matthewsinclair/intent/releases/download/v#{RELEASE_VERSION}/intentd-aarch64-apple-darwin"
    sha256 "847853b1eab193e500ff9dbb6aa7cbf03648412fb04f3d0742ed8ed4501fe063"
  end

  # The support tree the binaries read and exec: templates, hooks, guards, the
  # rule library, skills and subagents. Not signed and not notarised -- there is
  # no Mach-O in it. See SUPPORT_PATHS in bin/.devbin/cmd/macos.
  resource "support" do
    url "https://github.com/matthewsinclair/intent/releases/download/v#{RELEASE_VERSION}/intent-support.tar.gz"
    sha256 "ce6b7bd0a1a34efeb11f0f5d289d05feb2abedaa4bd4468768f83438cb5153ee"
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

    # THE EXECUTABLE BIT, AND IT IS NOT BELT-AND-BRACES -- WITHOUT IT THE KEG
    # INSTALLS AND NOTHING IN IT RUNS. GitHub serves release assets as plain
    # files with no exec bit, and Homebrew's `.install` PRESERVES the source
    # mode rather than setting one. So 644 goes in, 644 comes out, `brew
    # install` prints its beer emoji, and every `intent` call returns
    # `permission denied`. Measured on the v3.0.0 tap, 2026-08-26, on the first
    # real install from the network.
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
  # and the daemon's log are different files with different subjects.
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
