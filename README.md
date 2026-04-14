# Odin Book

Odin Book is a small social network built with Ruby on Rails. Users can sign up, create posts, comment, like posts, manage a profile, and send follow requests to other users.

## Features

- User authentication with Devise
- Auto-created profile for each new user
- Create, edit, and delete posts
- Comment on posts
- Like and unlike posts
- Send, accept, reject, and remove follow requests
- View all users, individual profiles, and each user's friends list
- Counter caches for post likes and comments

## Stack

- Ruby on Rails 8.0.5
- PostgreSQL
- Devise
- Hotwire (`turbo-rails`, `stimulus-rails`)
- Importmap
- Propshaft
- Solid Cache, Solid Queue, Solid Cable

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
- New accounts get a default profile whose display name starts as email prefix
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

## Notes

- Development database name: `project_odin_book_development`
- Test database name: `project_odin_book_test`
- `db/seeds.rb` is still placeholder and does not load sample social data

## Project Goal

This project matches Odin Book assignment style: build Facebook-like social features with authentication, profiles, posting, and follow/friend relationships in Rails.
