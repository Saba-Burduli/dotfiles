class SabaDotfiles < Formula
  desc "Reproducible macOS developer dotfiles and management command"
  homepage "https://github.com/Saba-Burduli/dotfiles"
  url "https://github.com/Saba-Burduli/dotfiles.git", branch: "main", using: :git
  version "0.1.0"
  license "MIT"

  depends_on :macos

  def install
    prefix.install Dir["*"]
    (bin/"dot").write_env_script prefix/"script/dot", DOTFILES_DIR: opt_prefix
  end

  test do
    system bin/"dot", "help"
  end
end
