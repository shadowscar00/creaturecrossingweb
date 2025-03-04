defmodule CreatureCrossingWeb.FakeContextTest do
  use CreatureCrossingWeb.DataCase

  alias CreatureCrossingWeb.FakeContext

  describe "animals" do
    alias CreatureCrossingWeb.FakeContext.Animal

    import CreatureCrossingWeb.FakeContextFixtures

    @invalid_attrs %{}

    test "list_animals/0 returns all animals" do
      animal = animal_fixture()
      assert FakeContext.list_animals() == [animal]
    end

    test "get_animal!/1 returns the animal with given id" do
      animal = animal_fixture()
      assert FakeContext.get_animal!(animal.id) == animal
    end

    test "create_animal/1 with valid data creates a animal" do
      valid_attrs = %{}

      assert {:ok, %Animal{} = animal} = FakeContext.create_animal(valid_attrs)
    end

    test "create_animal/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = FakeContext.create_animal(@invalid_attrs)
    end

    test "update_animal/2 with valid data updates the animal" do
      animal = animal_fixture()
      update_attrs = %{}

      assert {:ok, %Animal{} = animal} = FakeContext.update_animal(animal, update_attrs)
    end

    test "update_animal/2 with invalid data returns error changeset" do
      animal = animal_fixture()
      assert {:error, %Ecto.Changeset{}} = FakeContext.update_animal(animal, @invalid_attrs)
      assert animal == FakeContext.get_animal!(animal.id)
    end

    test "delete_animal/1 deletes the animal" do
      animal = animal_fixture()
      assert {:ok, %Animal{}} = FakeContext.delete_animal(animal)
      assert_raise Ecto.NoResultsError, fn -> FakeContext.get_animal!(animal.id) end
    end

    test "change_animal/1 returns a animal changeset" do
      animal = animal_fixture()
      assert %Ecto.Changeset{} = FakeContext.change_animal(animal)
    end
  end
end
