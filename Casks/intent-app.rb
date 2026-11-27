# RENDERED by devbin's formula built-in from the template below, for the tag
# below and the commit it names: edit the template, not this file, which the
# next render replaces.
#   template  packaging/homebrew/intent-app.rb
#   tag       v3.5.6
#   commit    7a540bfc552a0a293389013aebcd0a28abeb4538
cask "intent-app" do
  version "3.5.6"
  sha256 "ba0e86d2e1e1a719a6ae9bc8df61448ae9b25bf2e780fc698f76919511c7d7c3"

  url "https://github.com/matthewsinclair/intent/releases/download/v#{version}/Intent.app.zip"
  name "Intent"
  desc "Menubar app for Intent's steel thread process"
  homepage "https://github.com/matthewsinclair/intent"

  depends_on formula: "matthewsinclair/intent/intent"
  depends_on macos: :tahoe

  app "Intent.app"
end
