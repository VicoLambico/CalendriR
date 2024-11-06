# CalendriR

1) install PostgreSQL
2) Ajouter variable d'environnement dans PATH (scool jusqu'au image  https://stackoverflow.com/questions/30401460/postgres-psql-not-recognized-as-an-internal-or-external-command)

3) modifier le CalendriR>config>dev.exs :
   password: "mdp mis lors de l'instalation de PostgreSQL",

4) install phoenix :
   mix archive.install hex phx_new
   
5) Pour configurer votre base de données dans Phoenix exécuter la commande mix ecto.create

6) To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
