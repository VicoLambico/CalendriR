defmodule CalendriR.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CalendriR.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        description: "some description",
        end_time: ~N[2024-11-21 08:39:00],
        start_time: ~N[2024-11-21 08:39:00],
        team: "some team",
        title: "some title"
      })
      |> CalendriR.Events.create_event()

    event
  end
end
