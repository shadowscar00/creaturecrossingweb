defmodule CreatureCrossing do
  alias NimbleCSV.RFC4180, as: CSV
  alias CreatureCrossing.Creature

  @month_names %{
    1 => "January",
    2 => "February",
    3 => "March",
    4 => "April",
    5 => "May",
    6 => "June",
    7 => "July",
    8 => "August",
    9 => "September",
    10 => "October",
    11 => "November",
    12 => "December"
  }

  @time_to_clock %{
    0 => "12:00 AM",
    1 => "1:00 AM",
    2 => "2:00 AM",
    3 => "3:00 AM",
    4 => "4:00 AM",
    5 => "5:00 AM",
    6 => "6:00 AM",
    7 => "7:00 AM",
    8 => "8:00 AM",
    9 => "9:00 AM",
    10 => "10:00 AM",
    11 => "11:00 AM",
    12 => "12:00 PM",
    13 => "1:00 PM",
    14 => "2:00 PM",
    15 => "3:00 PM",
    16 => "4:00 PM",
    17 => "5:00 PM",
    18 => "6:00 PM",
    19 => "7:00 PM",
    20 => "8:00 PM",
    21 => "9:00 PM",
    22 => "10:00 PM",
    23 => "11:00 PM"
  }

  # Parses the passed CSV file and returns a list of Creature structs
  def parse_csv() do
    "data/creature_list.csv"
    |> File.stream!()
    |> CSV.parse_stream()
    |> Enum.map(fn [
                      name,
                      type,
                      opening_month,
                      closing_month,
                      opening_time,
                      closing_time,
                      location,
                      size,
                      speed,
                      weather,
                      special_note
                    ] ->
      {opening_month, _} = Integer.parse(opening_month)
      {closing_month, _} = Integer.parse(closing_month)
      {opening_time, _} = Integer.parse(opening_time)
      {closing_time, _} = Integer.parse(closing_time)

      %Creature{
        name: name,
        type: type,
        opening_month: opening_month,
        closing_month: closing_month,
        opening_time: opening_time,
        closing_time: closing_time,
        location: location,
        size: size,
        speed: speed,
        weather: weather,
        special_note: special_note
      }
    end)
  end

  # Populates a list of all creatures from the parsed CSV file and normalizes the months and times into ranges
  def populate_creatures_list() do
    _creatures =
      parse_csv()
      |> Enum.map(fn creature ->
        creature
        |> Map.put(:months, normalize_months(creature.opening_month, creature.closing_month))
        |> Map.put(:times, normalize_times(creature.opening_time, creature.closing_time))
      end)
  end

  # Takes a list of creatures and finds the most common month-time pair, and returns a list of all creatures that can be caught during that month-time pair
  def get_creatures_by_month_and_time(creatures) do
    {most_common_month, most_common_times} =
      creatures
      |> count_month_time_pairs()
      |> get_most_common_month_time()

    creatures
    |> get_most_common_creatures_by_time(List.first(most_common_times))
    |> get_most_common_creatures_by_month(most_common_month)
  end

  def get_best_time_to_catch(creatures) do
    {most_common_month, most_common_times} =
      creatures
      |> count_month_time_pairs()
      |> get_most_common_month_time()

    most_common_month_string = @month_names[most_common_month]

    starting_time_string = @time_to_clock[(List.first(most_common_times))]
    ending_time_string = @time_to_clock[(List.last(most_common_times) + 1)] # We add one so that the ending time is inclusive (as in, 9-4 catchable hours would end at 5)

    if List.first(most_common_times) == 0 && List.last(most_common_times) == 23 do
      "The best time to catch creatures is #{most_common_month_string}, all day."
    else
      "The best time to catch creatures is #{most_common_month_string}, starting at #{starting_time_string} and ending at #{ending_time_string}."
    end
  end

  def get_creatures_by_creature_type(creatures, type) do
    Enum.filter(creatures, fn creature -> creature.type == type end)
  end

  # Takes a creature's opening and closing months and normalizes them into a range of months
  def normalize_months(opening_month, closing_month) do
    if closing_month < opening_month do
      Enum.concat(Enum.to_list(opening_month..12), Enum.to_list(1..closing_month))
    else
      Enum.to_list(opening_month..closing_month)
    end
  end

  # Takes a creature's opening and closing times and normalizes them into a range of times
  defp normalize_times(opening_time, closing_time) do
    if closing_time < opening_time do
      Enum.concat(Enum.to_list(opening_time..23), Enum.to_list(0..closing_time))
    else
      Enum.to_list(opening_time..closing_time)
    end
  end

  # Takes a list of creatures and returns a map of months and the number of creatures that can be caught during that month
  def mutual_months(creatures) do
    creatures
    |> Enum.reduce(%{}, fn creature, accumulator_1 ->
      accumulator_1 =
        Enum.reduce(creature.months, accumulator_1, fn month, accumulator_2 ->
          Map.update(accumulator_2, month, 1, fn month_count -> month_count + 1 end)
        end)
    end)
  end

  # Takes a list of creatures and returns a map of times and the number of creatures that can be caught during those times
  def mutual_times(creatures) do
    creatures
    |> Enum.reduce(%{}, fn creature, accumulator_1 ->
      accumulator_1 =
        Enum.reduce(creature.times, accumulator_1, fn time, accumulator_2 ->
          Map.update(accumulator_2, time, 1, fn time_count -> time_count + 1 end)
        end)
    end)
  end

  # Takes a list of mutual months and returns the most common month
  def get_most_common_month(mutual_months) do
    {month, _month_count} = Enum.max_by(mutual_months, fn {_key, value} -> value end)
  end

  # Takes a list of mutual times and returns the most common time
  def get_most_common_time(mutual_times) do
    IO.inspect(mutual_times, label: "Mutual Times")
    {time, _time_count} = Enum.max_by(mutual_times, fn {_key, value} -> value end)
  end

  # Takes a list of month-time pairs and returns the most common month-time pair (a.k.a the month-time pair with the highest value)
  def get_most_common_month_time(pairs_count) do
    pairs_count =
      pairs_count
      |> Enum.group_by(fn {_month_time_pair, available_creature_count} -> available_creature_count end, fn {month_time_pair, _available_creature_count} -> month_time_pair end)
      |> Enum.max_by(fn {available_creature_count, _month_time_pair} -> available_creature_count end)
      |> elem(1) # takes the above tuple, and takes just the list of month_time_pairs (because elem(0) would be the available_creature_count)
      |> Enum.group_by(fn {month, _time} -> month end, fn {_month, time} -> time end)
      |> Enum.map(fn {month, times} -> {month, Enum.sort(times)} end)
      |> Enum.into(%{})

    most_common_month_time_pair = Enum.max_by(pairs_count, fn {_month, times} -> times end)

    times_list = most_common_month_time_pair |> elem(1) # takes the above tuple, and takes just the list of times (because elem(0) would be the month)
    |> group_contiguous()
    |> get_largest_time_overlap()

    {(most_common_month_time_pair |> elem(0)), times_list}

  end

  # Head = the current element of the list. Tail = the rest of the list.
  def group_contiguous([]), do: []

  def group_contiguous([head | tail]) do
    do_group_contiguous(tail, [[head]])
  end

  defp do_group_contiguous([], acc), do: acc |> Enum.reverse() |> Enum.map(&Enum.reverse(&1))

  defp do_group_contiguous([head | tail], [[prev_head | _] = prev_group | rest] = acc) do
    if head == prev_head + 1 do
      do_group_contiguous(tail, [[head | prev_group] | rest])
    else
      do_group_contiguous(tail, [[head] | acc])
  end
  end

  def get_largest_time_overlap(times_list) do

    [list_1 | rest] = times_list
    list_2 = Enum.at(rest, 0, [])
    list_3 = Enum.at(rest, 1, [])

    if List.first(list_1) == 0 && List.last(list_2) == 23 do
      Enum.concat(list_2, list_1)
    else
      if Enum.count(list_1) >= Enum.count(list_2) && Enum.count(list_1) >= Enum.count(list_3) do # If list_1 is biggest or all lists are equal length, return list_1
        list_1
      else
        if Enum.count(list_2) >= Enum.count(list_1) && Enum.count(list_2) >= Enum.count(list_3) do # If list_2 is biggest, return list_2
          list_2
        else
          list_3 # If no list is bigger than or equal to list_3, return list_3
        end
      end
    end
  end

  # Takes a list of creatures and returns a map of month-time pairs and the number of creatures that can be caught during that month-time pair
  def count_month_time_pairs(creatures) do
    creatures
    |> Enum.flat_map(fn creature ->
      months = normalize_months(creature.opening_month, creature.closing_month)
      times = normalize_times(creature.opening_time, creature.closing_time)
      for month <- months, time <- times, do: {month, time}
    end)
    |> Enum.frequencies()
  end

  # Takes a list of creatures and a month and returns a list of creatures that can be caught during that month
  def get_most_common_creatures_by_month(creatures, month) do
    Enum.filter(creatures, fn creature ->
      Enum.member?(creature.months, month)
    end)
  end

  # Takes a list of creatures and a time and returns a list of creatures that can be caught during that time
  def get_most_common_creatures_by_time(creatures, time) do
    Enum.filter(creatures, fn creature ->
      Enum.member?(creature.times, time)
    end)
  end

  def creature_time_availability_string(0, 24) do
    "All Day"
  end

  def creature_time_availability_string(opening_time, closing_time) do
    "#{@time_to_clock[opening_time]} to #{@time_to_clock[(closing_time)]}"
  end

  def creature_month_availability_string(1, 12) do
    "All Year"
  end

  def creature_month_availability_string(opening_month, closing_month) do
    "#{@month_names[opening_month]} to #{@month_names[closing_month]}"
  end
end
