module Livery
  module Controller
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Overrides +AbstractController#view_assigns+ to return
      # presenters set with the +present+ method.
      #
      # When you call this method in a controller class, instance
      # variables set in actions will no longer be shared with views.
      #
      # ==== Examples
      #
      #   # app/controllers/posts_controller.rb
      #   class PostController < ApplicationController
      #     include Livery::Controler
      #     use_presenters!
      #
      #     def show
      #       @post = Post.find(params[:id])
      #       present(post_presenter: @post)
      #     end
      #   end
      #
      # In this example, the instance variable +@post+ will not be
      # shared with the view. Instead, the +present+ method will
      # create a presenter-wrapped object available as
      # +@post_presenter+ in the view.
      def use_presenters!
        define_method "view_assigns" do
          @_presenters || {}
        end
      end
    end

    # Pass presenters to the view. Must be used with the class method
    # +use_presenters!+.
    #
    # +hsh+ A hash whose keys define the names of variables used in
    # the view, and values the objects that will be presented. Each
    # object must either be a presenter, or have a corresponding
    # presenter class; e.g., a +Post+ model should have a
    # +PostPresenter+ class. If an enumerable is passed, each object
    # within is mapped over. An exception is raised otherwise.
    #
    # ==== Examples
    #
    # +present+ will wrap non-presenter objects with their presenter
    # classes. Here, the +Post+ object is wrapped with a
    # +PostPresenter+:
    #
    #   # app/controllers/posts_controller.rb
    #   class PostsController < ApplicationController
    #     include Livery::Controller
    #     use_presenters!
    #
    #     def show
    #       post = Post.find(params[:id])
    #
    #       present(post: post)
    #     end
    #   end
    #
    # This is equivalent to (without using +use_presenters!+):
    #
    #   # app/controllers/posts_controller.rb
    #   class PostsController < ApplicationController
    #     def show
    #       post = Post.find(params[:id])
    #
    #       @post = PostPresenter.new(post)
    #     end
    #   end
    #
    # It can handle enumerables:
    #
    #   # app/controllers/posts_controller.rb
    #   class PostsController < ApplicationController
    #     include Livery::Controller
    #     use_presenters!
    #
    #     def index
    #       posts = Post.all
    #
    #       # Equivalent to:
    #       # @posts = posts.map { |post| PostPresenter.new(post) }
    #       present(posts: posts)
    #     end
    #   end
    #
    # And presenter objects will not be re-wrapped:
    #
    #   # app/controllers/posts_controller.rb
    #   class PostsController < ApplicationController
    #     include Livery::Controller
    #     use_presenters!
    #
    #     def show
    #       post_presenter = PostPresenter.new(current_user.post)
    #
    #       # Equivalent to:
    #       # @post = post_presenter
    #       present(post: post_presenter)
    #     end
    #   end
    #
    # Presenter classes are found via a simple naming convention; an
    # object of some class +Model+ will be wrapped with a
    # +ModelPresenter+. If a corresponding presenter class is not
    # found, an error is raised.
    def present(hsh)
      @_presenters ||= {}
      hsh.each_with_object(@_presenters) do |(k, v), acc|
        acc[k] = Livery::Presenter.to_presenter(v)
      end
    end
  end
end
