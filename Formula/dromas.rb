class Dromas < Formula
  desc "End-to-end encrypted, sender-authenticated messaging client for bots"
  homepage "https://dromas.dev"
  url "https://github.com/dromas-dev/dromas-client/archive/refs/tags/v0.6.14.tar.gz"
  sha256 "922899fb7be5c0c6b9881837e452b0ede23ba4d9e8e78478e106eb72d14b143a"
  license "Apache-2.0"
  head "https://github.com/dromas-dev/dromas-client.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/dromas-dev/homebrew-tap/releases/download/dromas-0.6.14"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "c7f6dc500e2dc2d91c7b930c69a44471460e0dfac7319b2986cf6a559b2c6f6a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "604c81d1d2cc422d8fcaad1f9429dc97e423126d0bae0108df5493496f7c9b10"
  end

  depends_on "go" => :build

  def install
    # A release's source archive carries no VCS information, so the build
    # records no version: the release is given at link time instead, as the
    # client's LinkedVersion says. A HEAD build is a git checkout, which Go
    # stamps itself. CGO off, as the release binaries are built.
    ENV["CGO_ENABLED"] = "0"
    ldflags = %w[-s -w]
    ldflags << "-X github.com/dromas-dev/dromas-client/client.LinkedVersion=v#{version}" unless build.head?
    system "go", "build", *std_go_args(ldflags:), "./cmd/dromas"
    system bin/"dromas", "gen-docs", "--man-dir", buildpath/"man"
    man1.install Dir[buildpath/"man/man1/*.1"]
    man5.install buildpath/"man/man5/dromas.toml.5"
    man7.install buildpath/"man/man7/dromas-output.7"
  end

  # The resident recv of the default profile, as the user. With --headers its
  # log gets who wrote each message and when, and none of the text a sender
  # chose: inbox/ keeps every message, and the profile's [recv] exec names the
  # program that runs for each, which gets the whole message.
  service do
    run [opt_bin/"dromas", "recv", "--follow", "--headers"]
    keep_alive true
    log_path var/"log/dromas.log"
    error_log_path var/"log/dromas.log"
  end

  test do
    assert_match "\"version\":\"v#{version}\"", shell_output("#{bin}/dromas version")
    assert_path_exists man1/"dromas.1"
  end
end
