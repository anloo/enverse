defmodule Enverse.Catalog do
  use Ash.Api

  resources do
    resource Enverse.Catalog.Dataset
    resource Enverse.Catalog.Record
  end
end
