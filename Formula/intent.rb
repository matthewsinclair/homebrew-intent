class Intent < Formula
  desc "Steel thread process for helping LLMs help you work with your code"
  homepage "https://github.com/matthewsinclair/intent"
  version "3.0.1"
  license "MIT"

  RELEASE_VERSION = "3.0.1".freeze

  # macOS arm64 only, by ruling (hv, 2026-08-15) rather than by omission. Both
  # binaries are Developer ID signed and notarised; nothing is stapled, because a
  # bare Mach-O has nowhere to hold a ticket and Gatekeeper checks online.
  on_macos do
    on_arm do
      url "https://github.com/matthewsinclair/intent/releases/download/v#{RELEASE_VERSION}/intent-aarch64-apple-darwin"
      sha256 "f1e6f38e24825acc48184ad19691526b5b53198df5e5ece702dec828cd83f3c1"

      resource "intentd" do
        url "https://github.com/matthewsinclair/intent/releases/download/v#{RELEASE_VERSION}/intentd-aarch64-apple-darwin"
        sha256 "ab125a565c3c94197b849654cf885f9faff4e89844ab9bce015a7fa3082878b3"
      end

      # The hooks and guards the binaries exec. Not signed and not notarised --
      # there is no Mach-O in it. See SUPPORT_ASSET in bin/.devbin/cmd/macos.
      resource "support" do
        url "https://github.com/matthewsinclair/intent/releases/download/v#{RELEASE_VERSION}/intent-support.tar.gz"
        sha256 "2ca6bb1c3507eb59c50c8b7d117f80b31f4548392870cec9641f9b5307e231d3"
      end
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
  # That rules IN two layouts and Homebrew rules one of them OUT. Installing to
  # `prefix/lib/templates` resolves correctly, but `lib` is a LINKED directory:
  # brew symlinks keg `lib` subdirectories into the shared prefix, so this would
  # publish a directory called `templates` into `#{HOMEBREW_PREFIX}/lib`
  # alongside 858 other formulae's entries. `templates` is about as generic as a
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
  # intentd writes its own structured log under the user's state dir; these two
  # capture stdout and stderr, where main.rs puts the warnings a supervised
  # process would otherwise drop on the floor. Two files, two subjects.
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
