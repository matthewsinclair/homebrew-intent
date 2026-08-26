class Intent < Formula
  desc "Steel thread process for helping LLMs help you work with your code"
  homepage "https://github.com/matthewsinclair/intent"
  version "3.0.0"
  license "MIT"
  revision 1

  RELEASE_VERSION = "3.0.0".freeze

  # macOS arm64 only, by ruling (hv, 2026-08-15) rather than by omission. Both
  # binaries are Developer ID signed and notarised; nothing is stapled, because a
  # bare Mach-O has nowhere to hold a ticket and Gatekeeper checks online.
  on_macos do
    on_arm do
      url "https://github.com/matthewsinclair/intent/releases/download/v#{RELEASE_VERSION}/intent-aarch64-apple-darwin"
      sha256 "04e7dda893b61529f3bc065bd23f009174a39f589acdbe8e0a8d55567145cf0b"

      resource "intentd" do
        url "https://github.com/matthewsinclair/intent/releases/download/v#{RELEASE_VERSION}/intentd-aarch64-apple-darwin"
        sha256 "7bf59bb52e2c4c15c3ae129daa0be17e60a0f6770e622072e6c2fea3d2dfda5c"
      end

      # The hooks and guards the binaries exec. Not signed and not notarised --
      # there is no Mach-O in it. See SUPPORT_ASSET in bin/.devbin/cmd/macos.
      resource "support" do
        url "https://github.com/matthewsinclair/intent/releases/download/v#{RELEASE_VERSION}/intent-support.tar.gz"
        sha256 "f5db2ff05a73c25fa550c1e9be196880389f51e3bc3405b87bfe6c4e2fb1c7c1"
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

  # NO `service do` BLOCK YET, and its absence is deliberate. intentd currently
  # reports "not yet implemented": there is no start verb and no log path, so any
  # block here would be a guess at an interface that does not exist. It arrives
  # with the daemon lifecycle.

  test do
    assert_match version.to_s, shell_output("#{bin}/intent --version")
  end
end
