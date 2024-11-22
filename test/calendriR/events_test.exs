defmodule CalendriR.EventsTest do
  use CalendriR.DataCase

  alias CalendriR.Events

  describe "events" do
    alias CalendriR.Events.Event

    import CalendriR.EventsFixtures

    @invalid_attrs %{state: nil, description: nil, title: nil, start_time: nil, end_time: nil, team: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{state: "some state", description: "some description", title: "some title", start_time: ~N[2024-11-21 10:33:00], end_time: ~N[2024-11-21 10:33:00], team: "some team"}

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
      assert event.state == "some state"
      assert event.description == "some description"
      assert event.title == "some title"
      assert event.start_time == ~N[2024-11-21 10:33:00]
      assert event.end_time == ~N[2024-11-21 10:33:00]
      assert event.team == "some team"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      update_attrs = %{state: "some updated state", description: "some updated description", title: "some updated title", start_time: ~N[2024-11-22 10:33:00], end_time: ~N[2024-11-22 10:33:00], team: "some updated team"}

      assert {:ok, %Event{} = event} = Events.update_event(event, update_attrs)
      assert event.state == "some updated state"
      assert event.description == "some updated description"
      assert event.title == "some updated title"
      assert event.start_time == ~N[2024-11-22 10:33:00]
      assert event.end_time == ~N[2024-11-22 10:33:00]
      assert event.team == "some updated team"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end
end
