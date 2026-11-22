# RENDERED by devbin's formula built-in from the template below, for the tag
# below and the commit it names: edit the template, not this file, which the
# next render replaces.
#   template  packaging/homebrew/intent-app.rb
#   tag       v3.5.1
#   commit    1cc654e5a36ef3cbe5d8d5aaa4ffc1dd5d096711
cask "intent-app" do
  version "3.5.1"
  sha256 "40048923e05435ab226034078c10e964193d0aa7ce64242645e08c19642ff689"

  url "https://github.com/matthewsinclair/intent/releases/download/v#{version}/Intent.app.zip"
  name "Intent"
  desc "Menubar app for Intent's steel thread process"
  homepage "https://github.com/matthewsinclair/intent"

  depends_on formula: "matthewsinclair/intent/intent"
  depends_on macos: :tahoe

  app "Intent.app"
end
