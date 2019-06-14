# Note: Migrate to PUID later. For now PUID is not being used
# Because the ID is also used for analytics.
defmodule(StabbyFlies.SocketIdGen, do: use(Puid))
