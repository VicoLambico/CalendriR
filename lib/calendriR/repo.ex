defmodule CalendriR.Repo do
  use Ecto.Repo,
    otp_app: :calendriR,
    adapter: Ecto.Adapters.Postgres
end
