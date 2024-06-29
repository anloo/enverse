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
        %{descriptor: descriptor} =
          Ash.Query.get_argument(query, :dataset)

        filters = criteria |> Enum.reduce(
          true,
          fn {key, value}, expr ->
            lookup = key |> to_string

            [variable, predicate] =
              case String.split(lookup, "__") do
                [variable, predicate] ->
                  [variable, predicate]
                [variable] ->
                  [variable, "eq"]
              end

            variable_descriptor = Enum.find(
              descriptor.variables,
              & &1.target_name == variable
            )

            case variable_descriptor do
              %{data_type: data_type} ->
                at_path = expr(get_path(^ref(:variables), ^variable))

                case predicate do
                  "eq" ->
                    expr(type(^at_path, ^data_type) == ^value and expr)
                  "gt" ->
                    expr(type(^at_path, ^data_type) > ^value and expr)
                  "gte" ->
                    expr(type(^at_path, ^data_type) >= ^value and expr)
                  "lt" ->
                    expr(type(^at_path, ^data_type) < ^value and expr)
                  "lte" ->
                    expr(type(^at_path, ^data_type) <= ^value and expr)
                end

              _ ->
                expr
            end

          end
        )
        Ash.Query.filter(query, ^filters)

      _ ->
        query
    end
  end

end
