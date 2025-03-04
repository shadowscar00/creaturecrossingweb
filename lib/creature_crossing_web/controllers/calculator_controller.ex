defmodule CreatureCrossingWeb.CalculatorController do
  use CreatureCrossingWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
