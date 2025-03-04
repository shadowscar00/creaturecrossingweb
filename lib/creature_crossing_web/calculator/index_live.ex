defmodule CreatureCrossingWeb.Calculator.IndexLive do
  use CreatureCrossingWeb, :live_view
  alias CreatureCrossing

  @impl true
  def mount(_params, _session, socket) do
    creatures = CreatureCrossing.populate_creatures_list()
    socket =
      socket
      |> assign(:creatures, creatures)
      |> assign(:fish, CreatureCrossing.get_creatures_by_creature_type(creatures, "Fish"))
      |> assign(:bugs, CreatureCrossing.get_creatures_by_creature_type(creatures, "Bug"))
      |> assign(:sea_creatures, CreatureCrossing.get_creatures_by_creature_type(creatures, "Sea Creature"))
      |> assign(:display_creatures_map, %{})
      |> assign(:best_time_string, "Press the button to calculate the best time to catch your missing creatures!")

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", %{"checkboxes" => checked_creatures} = _missing_creatures, socket) do
    checked_creatures_list = Enum.filter(socket.assigns.creatures, fn creature -> Enum.member?(checked_creatures, creature.name) end)
      |> CreatureCrossing.get_creatures_by_month_and_time()

    creature_display_map = Map.new(checked_creatures_list, fn creature -> {creature.name, creature} end)
      |> Enum.sort_by(fn {_, creature} -> creature.type end)

    socket = assign(socket, display_creatures_map: creature_display_map)
    socket = assign(socket, best_time_string: CreatureCrossing.get_best_time_to_catch(checked_creatures_list))

    CustomComponents.display_creature_info(socket.assigns)

    {:noreply, socket}
  end

  def handle_event("submit", _unsigned_params, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <.form phx-submit="submit" for={%{}} :let={_f}>
        <div class="flex items-center border-b border-zinc-100 py-3 justify-evenly">
          <div class="w-auto">
            <h2 class="block text-sm font-medium text-green-900">Select the fish you are missing:</h2>
              <div class="flex" style="background-color: var(--color-green-100); border-radius: var(--radius-md); border-style: solid; border-width: 5px; border-color: var(--color-green-800); padding: 5px">
                <CustomComponents.populate_creature_dropdown creatures={@fish} id="fish_selection"/>
              </div>
          </div>

          <div class="w-auto">
            <h2 class="block text-sm font-medium text-green-900">Select the bugs you are missing:</h2>
              <div class="flex" style="background-color: var(--color-green-100); border-radius: var(--radius-md); border-style: solid; border-width: 5px; border-color: var(--color-green-800); padding: 5px">
                <CustomComponents.populate_creature_dropdown creatures={@bugs} id="bug_selection"/>
              </div>
          </div>

          <div class="w-auto">
            <h2 class="block text-sm font-medium text-green-900">Select the sea creatures you are missing:</h2>
              <div class="flex" style="background-color: var(--color-green-100); border-radius: var(--radius-md); border-style: solid; border-width: 5px; border-color: var(--color-green-800); padding: 5px">
                <CustomComponents.populate_creature_dropdown creatures={@sea_creatures} id="sea_selection"/>
              </div>
          </div>
        </div>
          <div class="flex justify-center py-3 text-green-800">
            <button style="background-color: var(--color-amber-200); border-radius: var(--radius-md); border-style: solid; border-width: 5px; border-color: var(--color-green-800); padding: 5px" type="submit"><b>Calculate!</b></button>
          </div>
      </.form>
      <h2 class="text-center"> <%= @best_time_string %> </h2>
      <br>
      <div class="grid grid-cols-4 auto-rows-max flex">
        <CustomComponents.display_creature_info display_creatures_map={@display_creatures_map}/>
      </div>
    </section>
  """
  end
end
