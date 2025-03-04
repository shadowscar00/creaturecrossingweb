defmodule CreatureCrossingWeb.FakeContextFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CreatureCrossingWeb.FakeContext` context.
  """

  @doc """
  Generate a animal.
  """
  def animal_fixture(attrs \\ %{}) do
    {:ok, animal} =
      attrs
      |> Enum.into(%{})
      |> CreatureCrossingWeb.FakeContext.create_animal()

    animal
  end
end
