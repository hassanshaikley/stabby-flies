
defmodule StabbyFlies.PlayerTest do
    use ExUnit.Case, async: true
    alias StabbyFlies.Cloud
  
    setup do
      cloud =
        start_supervised!(
          {Cloud}
        )
  
      %{cloud: cloud}
    end

    test "initialization", %{cloud: cloud} do
        assert cloud.hp == 10

    end
  
end