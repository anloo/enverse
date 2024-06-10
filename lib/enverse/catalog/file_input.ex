defmodule Enverse.Catalog.FileInput do
  defstruct [:path, :name, :ext]

  def new(path) do
    new(path, path |> Path.basename)
  end

  def new(path, name) do
    %__MODULE__{path: path, name: name, ext: name |> Path.extname}
  end

end
