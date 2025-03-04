defmodule CreatureCrossing.Creature do
  defstruct [
    :name,
    :type,
    :opening_month,
    :closing_month,
    :opening_time,
    :closing_time,
    :location,
    :size,
    :speed,
    weather: "Any",
    special_note: nil
  ]
end
