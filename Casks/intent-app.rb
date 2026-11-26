# RENDERED by devbin's formula built-in from the template below, for the tag
# below and the commit it names: edit the template, not this file, which the
# next render replaces.
#   template  packaging/homebrew/intent-app.rb
#   tag       v3.5.4
#   commit    0eb2295119a074bdbc15939746986f28ab803a50
cask "intent-app" do
  version "3.5.4"
  sha256 "1c71b63c3b50f5cd12e6c6dced66beb570714f0353760e873b5e90a77c8c9d35"

  url "https://github.com/matthewsinclair/intent/releases/download/v#{version}/Intent.app.zip"
  name "Intent"
  desc "Menubar app for Intent's steel thread process"
  homepage "https://github.com/matthewsinclair/intent"

  depends_on formula: "matthewsinclair/intent/intent"
  depends_on macos: :tahoe

  app "Intent.app"
end
