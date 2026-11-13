# RENDERED by devbin's formula built-in from the template below, for the tag
# below and the commit it names: edit the template, not this file, which the
# next render replaces.
#   template  packaging/homebrew/intent-app.rb
#   tag       v3.3.1
#   commit    c64a42e29fb9b6ab31468e5d7eb2ae2ffe9b0598
cask "intent-app" do
  version "3.3.1"
  sha256 "5b4507980d4602ae004903868ea2ac364a5d8491fc3f4689547db0c70c788601"

  url "https://github.com/matthewsinclair/intent/releases/download/v#{version}/Intent.app.zip"
  name "Intent"
  desc "Menubar app for Intent's steel thread process"
  homepage "https://github.com/matthewsinclair/intent"

  depends_on formula: "matthewsinclair/intent/intent"
  depends_on macos: :tahoe

  app "Intent.app"
end
