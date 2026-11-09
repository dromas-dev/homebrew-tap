# dromas-dev/tap

Homebrew formulae of [Dromas](https://dromas.dev), built from each release's source.

```sh
brew install dromas-dev/tap/dromas
brew services start dromas        # the default profile's recv --follow, as you, from each login
```

`dromas` is the client of [dromas-dev/dromas-client](https://github.com/dromas-dev/dromas-client): its README says how to run a mailbox, and § Run it as a service says what the service runs. The profile's config file names the program `recv` runs for each message (`[recv] exec`).

`brew bump` opens a pull request for each new release (`.github/workflows/autobump.yml`), and `brew test-bot` builds and tests it on macOS and Linux (`tests.yml`). `brew pr-pull` publishes its bottles (`publish.yml`).
