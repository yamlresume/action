# Contributing

## Commit Messages

This repository uses [Release Please](https://github.com/googleapis/release-please) to automate releases. Release Please relies on [Conventional Commits](https://www.conventionalcommits.org/).

Please format your commit messages accordingly:

- `feat:` for new features (triggers a minor release)
- `fix:` for bug fixes (triggers a patch release)
- `chore:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:` for changes that do not affect the public API and shouldn't trigger a new release.

Prefixes that trigger a breaking change bump (major release):
- Appending `!` to the type/scope (e.g. `feat!: xxxx`)
- Including `BREAKING CHANGE:` in the footer.

## Release Process

1. Merge your changes to the `main` branch.
2. A GitHub Action automatically opens/updates a "Release PR".
3. Review the Release PR (it generates the Changelog and bumps versions).
4. When you are ready to cut a release, **merge the Release PR**.
5. Once merged, GitHub Actions will automatically tag the repository and publish the GitHub Release!
