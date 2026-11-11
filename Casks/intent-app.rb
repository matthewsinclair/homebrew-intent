# RENDERED by devbin's formula built-in from the template below, for the tag
# below and the commit it names: edit the template, not this file, which the
# next render replaces.
#   template  packaging/homebrew/intent-app.rb
#   tag       v3.3.0
#   commit    1e423060f919682db002e5335aee2b59586e623f
cask "intent-app" do
  version "3.3.0"
  sha256 "bc2add37b8600468306bbbc320ec3cee4948fa3d7b732f95286091245776c884"

  url "https://github.com/matthewsinclair/intent/releases/download/v#{version}/Intent.app.zip"
  name "Intent"
  desc "Menubar app for Intent's steel thread process"
  homepage "https://github.com/matthewsinclair/intent"

  depends_on formula: "matthewsinclair/intent/intent"
  depends_on macos: :tahoe

  app "Intent.app"
end
