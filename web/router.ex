defmodule Pxblog.Router do
  use Pxblog.Web, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", Pxblog do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)

    resources "/users", UserController do
      resources("/posts", PostController)
    end

    resources "/posts", PostController, only: [] do
      resources("/comments", CommentController, only: [:create, :delete, :update])
      resources("/likes", LikeController, only: [:create])
    end

    resources "/posts", PostController, only: [] do
      resources("/tags", TagController, only: [:create, :delete, :update])
    end

    resources("/sessions", SessionController, only: [:new, :create, :delete])
  end

  # Other scopes may use custom stacks.
  # scope "/api", Pxblog do
  #   pipe_through :api
  # end
end
