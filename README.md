# Assigned to Trello

Creates cards on a designated Trello board any time you're assigned an issue on GitHub.

[![Build Status](https://travis-ci.org/benbalter/assigned-to-trello.svg?branch=master)](https://travis-ci.org/benbalter/assigned-to-trello)

## Configuration

You must set the following environmental variables:

* `TRELLO_BOARD_ID` - In the URL for the board after `/b/`
* `TRELLO_LIST_NAME` - The column name, e.g., "To Do"
* `GITHUB_TOKEN` - A [GitHub personal access token](https://github.com/settings/tokens/new) with `repo` or `public_repo` scope
* `TRELLO_PUBLIC_KEY` - see below
* `TRELLO_MEMBER_TOKEN` - see below

### Generating a Trello key and token

1. Clone this repo locally
2. `script/bootstrap`
3. `bundle exec rake trello_token`
