defmodule Enverse.Catalog do
  use Ash.Domain

  resources do
    resource Enverse.Catalog.Dataset
    resource Enverse.Catalog.Record
  end
end
