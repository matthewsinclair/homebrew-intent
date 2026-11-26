# RENDERED by devbin's formula built-in from the template below, for the tag
# below and the commit it names: edit the template, not this file, which the
# next render replaces.
#   template  packaging/homebrew/intent-app.rb
#   tag       v3.5.5
#   commit    0bab786dc32d336fdc3c96b6c3c562e9a82134da
cask "intent-app" do
  version "3.5.5"
  sha256 "c288cb3f04fa53ecfaccfff773ab99c39961cd1f2438076e4f2d7037f3013923"

  url "https://github.com/matthewsinclair/intent/releases/download/v#{version}/Intent.app.zip"
  name "Intent"
  desc "Menubar app for Intent's steel thread process"
  homepage "https://github.com/matthewsinclair/intent"

  depends_on formula: "matthewsinclair/intent/intent"
  depends_on macos: :tahoe

  app "Intent.app"
end
