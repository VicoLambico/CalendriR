defmodule CalendriR.TeamsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CalendriR.Teams` context.
  """

  @doc """
  Generate a team.
  """
  def team_fixture(attrs \\ %{}) do
    {:ok, team} =
      attrs
      |> Enum.into(%{
        admin: "some admin",
        description: "some description",
        name: "some name",
        teammates: "some teammates"
      })
      |> CalendriR.Teams.create_team()

    team
  end
end
