defprotocol Enverse.Catalog.Ingestible do

  def to_schema(data)

  def to_stream(data)

end
