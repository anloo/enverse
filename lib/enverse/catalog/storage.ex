defmodule Enverse.Catalog.Storage do
  @root_path "priv/data"

  alias Enverse.Catalog.FileInput

  def put(path, file) when is_binary(file) do
    put(path, FileInput.new(file))
  end

  def put(path, file) when is_struct(file, FileInput) do
    File.copy!(file.path, path |> Path.join(file.name))
  end

  def put(path, files) when is_list(files) do
    curr_batch = @root_path |> Path.join(path)
    next_batch = @root_path |> Path.join(path <> ".in")

    File.mkdir_p!(curr_batch)
    File.cp_r!(curr_batch, next_batch)

    copied_bytes = files |> Enum.reduce(0,
      fn f, b ->
        b + put(next_batch, f)
      end
    )

    File.rmdir!(curr_batch)
    File.rename!(next_batch, curr_batch)

    copied_bytes
  end

  def list(path, glob \\ "*") do
    [@root_path, path, glob]
    |> Path.join()
    |> Path.wildcard()
    |> Enum.map(&FileInput.new/1)
  end
end
