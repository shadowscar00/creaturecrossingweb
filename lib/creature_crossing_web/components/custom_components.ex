defmodule CustomComponents do
  use CreatureCrossingWeb, :html
  use Phoenix.Component

  alias CreatureCrossing

  attr :id, :string, required: true
  attr :creatures, :list, required: true

  def populate_creature_dropdown(assigns) do
    ~H"""
    <div id="{@id}" class="w-full">
      <ul style="max-height:175px; overflow:scroll;">
        <%= for creature <- @creatures do %>
          <li>
            <input
              field={:creature}
              id={creature.name}
              type="checkbox"
              name="checkboxes[]"
              value={creature.name}
            /> <label for={creature.name}>{creature.name}</label>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  attr :display_creatures_map, :map, required: true

  def display_creature_info(assigns) do
    ~H"""
    <%= for {name, creature} <- @display_creatures_map do %>
      <div
        class="bg-green-50"
        style="border-radius: var(--radius-md); border-style: dotted; border-width: 2px; border-color: var(--color-green-800); padding: 5px"
      >
        <h2><b>{name}</b></h2>
         <br />
        <p>
          <b>Time of Year:</b> {CreatureCrossing.creature_month_availability_string(
            creature.opening_month,
            creature.closing_month
          )}
        </p>

        <p>
          <b>Time of Day:</b> {CreatureCrossing.creature_time_availability_string(
            creature.opening_time,
            (creature.closing_time + 1)
          )}
        </p>

        <p><b>Weather:</b> {creature.weather}</p>

        <%= if creature.type == "Fish" do %>
          <p><b>Location: </b>{creature.location}</p>

          <p><b>Size: </b>{creature.size}</p>
        <% end %>

        <%= if creature.type == "Bug" do %>
          <p><b>Location:</b> {creature.location}</p>
        <% end %>

        <%= if creature.type == "Sea Creature" do %>
          <p><b>Size:</b> {creature.size}</p>

          <p><b>Speed:</b> {creature.speed}</p>
        <% end %>

        <p><b>Special Note:</b> {creature.special_note}</p>
         <br />
      </div>
    <% end %>
    """
  end
end
