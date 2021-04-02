defmodule Discuss.UserSocket do
  use Phoenix.Socket

  alias Discuss.User

  channel "comments:*", Discuss.CommentsChannel

  transport :websocket, Phoenix.Transports.WebSocket

  def connect(%{ "token" => token}, socket) do
    case Phoenix.Token.verify(socket, "random_key", token) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}
      {:error, _reason} ->
        :error
    end
  end

  def id(_socket), do: nil
end
