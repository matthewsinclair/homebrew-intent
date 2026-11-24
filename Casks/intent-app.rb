# RENDERED by devbin's formula built-in from the template below, for the tag
# below and the commit it names: edit the template, not this file, which the
# next render replaces.
#   template  packaging/homebrew/intent-app.rb
#   tag       v3.5.2
#   commit    fabbffd8cb9ee05c0c8343e8a2b7309c372a30cd
cask "intent-app" do
  version "3.5.2"
  sha256 "ad233612fc9bd06525d8cb4157fa9e1088643551e52f6719dd44718b49855704"

  url "https://github.com/matthewsinclair/intent/releases/download/v#{version}/Intent.app.zip"
  name "Intent"
  desc "Menubar app for Intent's steel thread process"
  homepage "https://github.com/matthewsinclair/intent"

  depends_on formula: "matthewsinclair/intent/intent"
  depends_on macos: :tahoe

  app "Intent.app"
end
