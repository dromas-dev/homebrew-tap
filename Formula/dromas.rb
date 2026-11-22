class Dromas < Formula
  desc "End-to-end encrypted, sender-authenticated messaging client for bots"
  homepage "https://dromas.dev"
  url "https://github.com/dromas-dev/dromas-client/archive/refs/tags/v0.6.10.tar.gz"
  sha256 "db18070ca4ddd7eeb4feb851fc8cb2f24be5c03e6abf3f8e76af6f73dd210763"
  license "Apache-2.0"
  head "https://github.com/dromas-dev/dromas-client.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/dromas-dev/homebrew-tap/releases/download/dromas-0.6.8"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "6c2d2ff9bfea4c6965812ec1ba60bd73c074eb15abd6f37cad698a3e246aac10"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "4c2f555dd7fc08b84fb54096d75c2885878bf9d6ed670d3f28ce5cf8e4f7d58e"
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
