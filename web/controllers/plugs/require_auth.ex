defmodule Discuss.Plugs.RequireAuth do
    import Plug.Conn
    import Phoenix.Controller

    alias Discuss.Router.Helpers

    def init(_params) do
    end

    def call(conn, _init_result) do
        if conn.assigns[:user] do
            conn
        else
            conn
            |> put_flash(:error, "Please, sign in first!")
            |> redirect(to: Helpers.topic_path(conn, :index))
            |> halt()
        end
    end
end