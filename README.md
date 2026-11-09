# Circle POS Test

A Rails service that completes an ISBN-13. Send the first 12 digits and it calculates the check digit and returns the full 13-digit ISBN.

## Requirements

- Ruby 4.0.5 (see `.ruby-version`)
- Bundler

The app uses Rails 8.1 and SQLite, but ISBN data isn't stored, so there are no migrations to run.

## Getting started

```sh
bin/setup
```

This installs the gems, prepares the database, and starts the server at <http://localhost:3000>. To set up without starting the server, run `bin/setup --skip-server`, then use `bin/dev` whenever you want to start it.

## API

### `POST /api/v1/isbns`

Send a JSON body with `isbn` as a **string** of exactly 12 digits. Hyphens, spaces between digits, and letters are rejected. Whitespace before or after the digits is trimmed.

```sh
curl -X POST http://localhost:3000/api/v1/isbns \
  -H "Content-Type: application/json" \
  -d '{"isbn": "978030640615"}'
```

A successful request returns `200 OK`:

```json
{
  "data": {
    "prefix": "978030640615",
    "check_digit": 7,
    "isbn13": "9780306406157"
  }
}
```

Errors all have the same shape:

```json
{
  "error": {
    "code": "missing_parameter",
    "message": "isbn is required",
    "field": "isbn"
  }
}
```

| Status | `code` | Meaning |
|---|---|---|
| 400 | `missing_parameter` | `isbn` wasn't sent |
| 400 | `invalid_type` | `isbn` isn't a string, for example a JSON number, which would lose leading zeros |
| 400 | `too_long` | `isbn` is longer than 64 characters |
| 422 | `invalid_isbn` | `isbn` is empty, contains anything other than digits, or isn't exactly 12 digits |

### Other routes

| Route | Purpose |
|---|---|
| `GET /` and `GET /isbns/new` | Web form (see [Known issues](#known-issues)) |
| `POST /isbns` | Web form submission |
| `GET /up` | Health check; returns 200 if the app boots |

## How the check digit is calculated

Each of the 12 digits is multiplied by a weight that alternates between 1 and 3, starting with 1. The products are added together, and the check digit is `(10 - (sum % 10)) % 10`.

For `978030640615`, the sum is 93, so the check digit is `(10 - 3) % 10 = 7`.

## Code layout

An API request passes through these layers:

| Layer | File | Responsibility |
|---|---|---|
| Controller | `app/controllers/api/v1/isbns_controller.rb` | Connects the layers and sets the HTTP status |
| Request object | `app/requests/isbn_request.rb` | Checks the parameter is present, a string, and within the length limit |
| Service | `app/services/isbn.rb` | Validates the ISBN format and calculates the check digit |
| Serializer | `app/serializers/isbn_serializer.rb` | Builds the success and error JSON |

The web form uses `app/controllers/isbns_controller.rb`, which calls the same `Isbn` service directly.

## Development

```sh
bin/rails test                                # Run all tests
bin/rails test test/services/isbn_test.rb     # Run one file
bin/rails test test/services/isbn_test.rb:12  # Run the test at a given line

bin/rubocop                                   # Lint
bin/brakeman --no-pager                       # Static security analysis
bin/bundler-audit                             # Check gems for known vulnerabilities
```

## Known issues

- **The web form doesn't render.** `app/views/isbns/new.html.erb` doesn't exist, so the form page and form submissions fail, and three tests in `test/controllers/isbns_controller_test.rb` don't pass. The JSON API isn't affected.
- **`bin/ci` and the GitHub Actions `scan_js` job fail** because they run `bin/importmap audit`, and `bin/importmap` doesn't exist.
- **Production deployment isn't configured yet.** `config/deploy.yml` (Kamal) still has a placeholder server and registry. `config/cache.yml` and `config/queue.yml` are missing even though `config/deploy.yml` enables Solid Queue.
