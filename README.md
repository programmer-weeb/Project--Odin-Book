# Odin Book

Odin Book is a small social network built with Ruby on Rails. Users sign up, post, comment, like posts, edit a profile, and send follow requests.

[**Live Demo**](https://ahmed-odin-book.onrender.com/) — log in with `alex@example.com` / `password123`.

## Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Stack](#stack)
- [Data Model](#data-model)
- [App Behavior](#app-behavior)
- [Routes](#routes)
- [Local Setup](#local-setup)
- [Running the App](#running-the-app)
- [Running Tests and Checks](#running-tests-and-checks)
- [Continuous Integration](#continuous-integration)
- [Render Deploy](#render-deploy)
- [Notes](#notes)
- [Project Goal](#project-goal)
- [License](#license)

## Features

- Email/password authentication with Devise
- Sign in with Google via OmniAuth (`omniauth-google-oauth2`)
- Auto-created profile for each new user
- Create, edit, and delete posts
- Comment on posts
- Like and unlike posts
- Send, accept, reject, and remove follow requests
- View all users, individual profiles, and each user's friends list
- Counter caches for post likes and comments
- Rate limiting on auth and content-creation endpoints (Rack::Attack)
- Pagination on feed, profile posts, user directory, and friends list (pagy)
- Profile photo upload with size/type validation and one-click removal
- Live photo preview via Stimulus before upload
- Live comment updates via ActionCable / Turbo Streams (new and deleted comments show up for every viewer without a refresh)
- Live like-count updates via ActionCable / Turbo Streams
- Global search at `/search`. Matches display name and handle prefix, not full email (to avoid email enumeration), and excludes the current user
- Friends-only feed: `/?scope=friends` filters the feed to the current user and their accepted friends
- Pending follow-request count badge in the navbar. Updates live across the recipient's tabs via ActionCable when the sender creates or cancels a request, or when the recipient accepts or rejects it
- Comment delete button is restored after an ActionCable broadcast by the `comment-visibility` Stimulus controller

## Screenshots

<!-- Drop screenshots or a short GIF of the feed + live comments here, e.g.:
![Feed](docs/screenshots/feed.png)
![Live comments](docs/screenshots/live-comments.gif)
-->

## Stack

- Ruby 4.0.2 (see `.ruby-version`)
- Ruby on Rails 8.0.5
- PostgreSQL
- Devise + OmniAuth (Google)
- Hotwire (`turbo-rails`, `stimulus-rails`)
- Tailwind CSS (`tailwindcss-rails`)
- Importmap
- Propshaft
- Solid Cache, Solid Queue, Solid Cable
- Active Storage variants via `image_processing` (mini_magick backend)
- Rack::Attack rate limiting
- Pagy pagination

## Data Model

Main models:

- `User`
- `Profile`
- `Post`
- `Comment`
- `Like`
- `UserFollowRequest`

Relationship summary:

- `User` has one `Profile`
- `User` has many `Posts`, `Comments`, and `Likes`
- `Post` belongs to `User` and has many `Comments` and `Likes`
- `Comment` belongs to `User` and `Post`
- `Like` belongs to `User` and `Post`
- `UserFollowRequest` connects one user to another with `pending`, `accepted`, or `rejected` status

## App Behavior

- Root path goes to posts feed: `/`
- All main features require authentication
- New accounts get a default profile whose display name starts as the email prefix
- Users can delete their own likes
- Users can delete their own comments, and post owners can also delete comments on their posts
- Users can edit and delete only their own posts
- Friendship is derived from accepted follow requests in either direction

## Routes

Main routes:

- `devise_for :users` (including the Google OmniAuth callback at `/users/auth/google_oauth2/callback`)
- `resources :posts, shallow: true` with nested `comments` and `likes`. Shallow nesting means member URLs are `/posts/:id`, `/comments/:id`, and `/likes/:id` (no parent prefix on the member routes)
- `resources :users, only: [:index, :show]` with nested `follow_requests` for creation and a `friends` member route
- `resources :follow_requests, only: [:index, :destroy]` with `accept`, `reject`, `received`, and `sent`
- `resource :profile, only: [:edit, :update]` with `DELETE /profile/photo`
- `GET /search`
- `GET /up` — Rails health check (used by Render)

## Local Setup

### Requirements

- Ruby 4.0.2 (see `.ruby-version`)
- Bundler
- PostgreSQL running locally
- ImageMagick (for Active Storage image variants via mini_magick)

### Install

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
```

Or use the setup script (runs the first two):

```bash
bin/setup
```

### Seed Data

`db/seeds.rb` builds a demo dataset: 20 users with profiles, posts, comments, likes, and a small follow graph. Every seeded user shares the password `password123`. A few examples to log in with locally:

- `alex@example.com`
- `maya@example.com`
- `omar@example.com`

To reset and reseed the dev database:

```bash
bin/rails db:reset
```

## Running the App

Start the server:

```bash
bin/dev
```

Then open:

```text
http://localhost:3000
```

`bin/dev` currently only starts the Rails server. If you are editing Tailwind classes, run the watcher in a second terminal so CSS rebuilds on save:

```bash
bin/rails tailwindcss:watch
```

Alternatively, build CSS once with `bin/rails tailwindcss:build`. CSS is also rebuilt automatically as part of `assets:precompile` in production.

## Running Tests and Checks

Run the full test suite (unit + integration + system):

```bash
bin/rails db:test:prepare test test:system
```

Just the unit and integration tests:

```bash
bin/rails test
```

Static analysis and linting (mirror what CI runs):

```bash
bin/brakeman           # security scan
bin/rubocop            # style
bin/importmap audit    # JS dependency advisories
```

## Continuous Integration

GitHub Actions (`.github/workflows/ci.yml`) runs on every push to `main` and on every pull request. It runs, in parallel:

- `bin/brakeman --no-pager`
- `bin/importmap audit`
- `bin/rubocop -f github`
- `bin/rails db:test:prepare test test:system` against a Postgres service container (screenshots from failed system tests are uploaded as artifacts)

## Render Deploy

To deploy to Render:

1. Push the repo to GitHub.
2. Create a Render Web Service from the repo.
3. Create a Render PostgreSQL database and connect it to the service as `DATABASE_URL`.
4. Add these environment variables in Render:
   - `RAILS_MASTER_KEY` — required
   - `APP_HOST` — optional. Defaults to `RENDER_EXTERNAL_HOSTNAME`, which Render injects automatically, so you only need to set this if you use a custom domain
   - `SECRET_KEY_BASE` — optional. Rails reads it from encrypted credentials when `RAILS_MASTER_KEY` is set; only set this env var if you need to override that
   - `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` — only if you want Google sign-in enabled (they can also be stored in credentials)
5. Attach a persistent disk mounted at `/rails/storage` so uploaded profile photos survive deploys.

Suggested Render settings:

- Build command: `bundle install && bundle exec rails assets:precompile`
- Pre-deploy / release command: `bundle exec rails db:prepare` (runs pending migrations before each release; safe on first deploy too)
- Start command: `./bin/rails server -b 0.0.0.0 -p $PORT`
- Health check path: `/up`
- Ensure the build environment has ImageMagick installed (Render's default Ruby builder includes it). The app uses `mini_magick` for Active Storage variants. If migrating to a base image without ImageMagick, install it via apt or switch the variant processor to `:vips`.

If you keep Google OAuth enabled, add this callback URL in Google Cloud:

```text
https://your-app.onrender.com/users/auth/google_oauth2/callback
```

## Notes

- Development database name: `project_odin_book_development`
- Test database name: `project_odin_book_test`
- Health check endpoint: `GET /up`
- Reset and reseed the dev database with `bin/rails db:reset`

## Project Goal

Built for The Odin Project's Odin Book assignment: Facebook-style social features (auth, profiles, posts, friend requests) in Rails.

## License

Released under the [MIT License](LICENSE).
