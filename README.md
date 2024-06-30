# Livery

A simple presenter library for Rails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'livery'
```

## Usage

Presenter classes that wrap models should be named
`[ModelName]Presenter`, and inherit from `Livery::Presenter`.

The underlying model object is called a `resource`, and is passed in
initialization. Let's say we have a `Post` model:

```ruby
# app/models/post.rb

class Post < ApplicationRecord
  # title: string, body: text
  belongs_to :author
end
```

An empty `PostPresenter` would look like:

```ruby
# app/presenters/post_presenter.rb

class PostPresenter < Livery::Presenter
  resource :post
end
```

By default, no methods are added except `resource` and, as an alias,
the name of the resource; in this case `post`. So you should define
methods or explicitly delegate them to the underlying object:

```ruby
# app/presenters/post_presenter.rb

class PostPresenter < Livery::Presenter
  resource :post

  delegate :title,
           :body,
           to: :post

  def posted_at
    if post.created_at.present?
      post.created_at.strftime('%a, %b %d %Y')
    else
      'Not posted yet'
    end
  end
end

# example:
post = Post.new title: 'An aviation point of view'
post_presenter = PostPresenter.new(post)
post_presenter.title # => 'An aviation point of view'
post_presenter.posted_at # => 'Not posted yet'
```

### Controllers

Livery provides some convenience methods to wrap model objects with
presenters, and to ensure that only presenters are passed to the view:

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  include Livery::Controller # add this line
end
```

The `use_presenters!` method overrides `view_assigns` so that instance
variables are not passed to views. It also defines a `present()`
method to explicitly pass them:

```ruby
# app/controllers/posts_controller.rb

class PostsController < ApplicationController
  use_presenters!

  def show
    @post = Post.find(params[:id])
    present(current_post: @post)
  end
end
```

`present` will find the `PostPresenter` class to wrap the `@post`
model object, and assign it to the `@current_post` instance variable
in the view:

```erb
# app/views/posts/show.html.erb:

<h1><%= @current_post.title ></h1>
<h2>Posted at <%= @current_post.posted_at %></h2>
```

### Presenter associations

Given an associated model (`post.author`) with a presenter class:

```ruby
class AuthorPresenter < Livery::Presenter
  resource :author

  def full_name
    author.given_name + ' ' + author.surname
  end
end
```

you can use `presenter_association`:

```ruby
class PostPresenter < Livery::Presenter
  resource :post

  presenter_association :author

  # ...
end

PostPresenter.new(post).author.full_name # => "Amelia Earhart"
```

## Development

Run `bin/rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version, update the version number in `version.rb`,
and then run `bundle exec rake release`, which will create a git tag
for the version, push git commits and tags, and push the `.gem` file
to [rubygems.org](https://rubygems.org).
