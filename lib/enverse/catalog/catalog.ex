defmodule Enverse.Catalog do
  use Ash.Api

  resources do
    resource Enverse.Catalog.Dataset
  end
end
