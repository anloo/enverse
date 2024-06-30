defmodule Enverse.Catalog.Record.Preparations.Filters do
  use Ash.Resource.Preparation

  # Prepare query with filters ...
  def prepare(query, _, _) do
    query
    |> filter_between()
    |> filter_within()
    |> filter_by_criteria()
  end

  # ...in time
  defp filter_between(query) do
    case Ash.Query.get_argument(query, :between) do
      [from_date] ->
        Ash.Query.filter(query, time >= ^from_date)
      [from_date, to_date] ->
        Ash.Query.filter(query, time >= ^from_date and time <= ^to_date)
      _ ->
        query
    end
  end

  # ...in space
  defp filter_within(query) do
    case Ash.Query.get_argument(query, :within) do
      # Bounding Box
      [min_x, min_y, max_x, max_y] ->
        srid = 4326
        Ash.Query.filter(
          query,
          fragment(
            # TODO: Should be extracted to a custom expression when
            # this kind of queries is settled. Also see note about
            # polygon below.
            """
            ST_Contains(
              ST_MakeEnvelope(?, ?, ?, ?, ?),
              ST_Point(?, ?, ?)
            )
            """,
            ^min_x, ^min_y, ^max_x, ^max_y, ^srid, #ST_MakeEnvelope
            expr(longitude), expr(latitude), ^srid #ST_Point
          )
        )

      # TODO: Add case of polygon
      # %SomePolygonStruct{} = polygon ->
      #   NOTES: ST_Polygon('LINESTRING(x y, x y, ...)::geometry', srid)
      #   works just fine but mechanisms for dealing with such input
      #   types as well as postgrex types needs to be in place first.

      _ ->
        query
    end
  end

  # ...by any other criteria
  defp filter_by_criteria(query) do
    case Ash.Query.get_argument(query, :criteria) do
      criteria when is_map(criteria) ->
        Enum.reduce(criteria, query, & filter_variable(&2, &1))
      _ ->
        query
    end
  end

  defp filter_variable(query, {variable, predicate}) do
    case check_variable(query, variable) do
      {:ok, %{data_type: type}} ->
        Ash.Query.filter(
          query,
          ^filter_variable_expr(variable, predicate, type)
        )
      {:error, error} ->
        Ash.Query.add_error(query, error)
    end
  end

  defp filter_variable_expr(variable, predicate, type) do
    base_expr = expr(get_path(^ref(:variables), ^variable))

    case predicate do
      %{eq: value} ->
        expr(type(^base_expr, ^type) == ^value)
      %{not_eq: value} ->
        expr(type(^base_expr, ^type) != ^value)
      %{gt: value} ->
        expr(type(^base_expr, ^type) > ^value)
      %{gte: value} ->
        expr(type(^base_expr, ^type) >= ^value)
      %{lt: value} ->
        expr(type(^base_expr, ^type) < ^value)
      %{lte: value} ->
        expr(type(^base_expr, ^type) <= ^value)
      %{in: value} when is_list(value) ->
        expr(type(^base_expr, ^type) in ^value)
    end
  end

  defp check_variable(query, variable) do
    %{descriptor: %{variables: variables}} =
      Ash.Query.get_argument(query, :dataset)

    case Enum.find(variables, & &1.target_name == to_string(variable)) do
      descriptor when is_map(descriptor) ->
        {:ok, descriptor}
      nil ->
        {:error, "Invalid variable"}
    end
  end

end
