## Setup

In order to deploy a new version of the gem into the wild ...

You will need to configure your github api token for the changelog.

Generate a new token for changelogs [here](https://github.com/settings/tokens/new).

add:

```bash
export CHANGELOG_GITHUB_TOKEN=YOUR_CHANGELOG_API_TOKEN
```

somewhere in your shell init. (ie .zshrc or simillar)

## Deploying

1. Update `lib/dispatch-rider/version.rb`
2. Commit the changed files with the version number eg: `1.8.0`
3. Push this to git
4. Run `rake release`
5. Run `rake changelog` (has to be ran after release since its based on github tagging)
6. Commit the changed changelog named something like `changelog for 1.8.0`
7. Push this to git
