defmodule Pxblog.Repo do
  use Ecto.Repo, otp_app: :pxblog
  use Scrivener, page_size: 10
end
