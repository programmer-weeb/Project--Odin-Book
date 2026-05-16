# Odin Book

Odin Book is a small social network built with Ruby on Rails. Users sign up, post, comment, like posts, edit a profile, and send follow requests.

[**Live Demo**](https://ahmed-odin-book.onrender.com/)
Login with `alex@example.com` / `password123`.

## Features

- User authentication with Devise
- Auto-created profile for each new user
- Create, edit, and delete posts
- Comment on posts
- Like and unlike posts
- Send, accept, reject, and remove follow requests
- View all users, individual profiles, and each user's friends list
- Counter caches for post likes and comments
- Rate limiting on auth and content-creation endpoints (Rack::Attack)
- Pagination on feed, profile posts, user directory, friends list (pagy)
- Profile photo upload with size/type validation and one-click removal
- Live photo preview via Stimulus before upload
- Live comment updates via ActionCable / Turbo Streams (new and deleted comments show up for every viewer without a refresh)
- Live like-count updates via ActionCable / Turbo Streams
- Global search at `/search`. Matches display name and handle prefix, not full email (to avoid email enumeration), and excludes the current user
- Friends-only feed: `?scope=friends` filters the feed to the current user and their accepted friends
- Pending follow-request count badge in the navbar. Updates live across the recipient's tabs via ActionCable when the sender creates or cancels a request, or when the recipient accepts or rejects it
- Comment delete button is restored after an ActionCable broadcast by the `comment-visibility` Stimulus controller

## Stack

- Ruby on Rails 8.0.5
- PostgreSQL
- Devise
- Hotwire (`turbo-rails`, `stimulus-rails`)
- Importmap
- Propshaft
- Solid Cache, Solid Queue, Solid Cable
- Active Storage variants via image_processing (mini_magick backend)
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

- `devise_for :users`
- `resources :posts` with nested `comments` and `likes`
- `resources :users, only: [:index, :show]`
- `resources :follow_requests` with `accept`, `reject`, `received`, and `sent`
- `resource :profile, only: [:edit, :update]`

## Local Setup

### Requirements

- Ruby compatible with Rails 8
- Bundler
- PostgreSQL running locally
- ImageMagick (for Active Storage image variants via mini_magick)

### Install

```bash
bundle install
bin/rails db:prepare
```

Or use setup script:

```bash
bin/setup
```

## Running App

Start server:

```bash
bin/dev
```

Then open:

```text
http://localhost:3000
```

## Running Tests

Run full test suite:

```bash
bin/rails test
```

## Render Deploy

To deploy to Render:

1. Push the repo to GitHub.
2. Create a Render Web Service from the repo.
3. Create a Render PostgreSQL database and connect it to the service as `DATABASE_URL`.
4. Add these environment variables in Render:
   - `RAILS_MASTER_KEY`
   - `SECRET_KEY_BASE`
   - `APP_HOST` set to your Render hostname, for example `your-app.onrender.com`
   - `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` only if you want Google sign-in enabled
5. Attach a persistent disk mounted at `/rails/storage` so uploaded profile photos survive deploys.

Suggested Render settings:

- Build command: `bundle install && bundle exec rails assets:precompile`
- Start command: `./bin/rails server -b 0.0.0.0 -p $PORT`
- Ensure the build environment has ImageMagick installed (Render's default Ruby builder includes it). The app uses mini_magick for Active Storage variants. If migrating to a base image without ImageMagick, install it via apt or switch the variant_processor to :vips.

If you keep Google OAuth enabled, add this callback URL in Google Cloud:

```text
https://your-app.onrender.com/users/auth/google_oauth2/callback
```

## Notes

- Development database name: `project_odin_book_development`
- Test database name: `project_odin_book_test`

## Project Goal

Built for The Odin Project's Odin Book assignment: Facebook-style social features (auth, profiles, posts, friend requests) in Rails.
