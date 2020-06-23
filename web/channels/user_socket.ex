defmodule Discuss.UserSocket do
  use Phoenix.Socket

  channel "comments:*", Discuss.CommentsChannel

  transport :websocket, Phoenix.Transports.WebSocket
  
  # Function: connect
  # _________________
  #   - called when Socket object is instatiated in socket.js and passes in generated token from window
  #   - verifies token and if valid, assigns user_id property to socket.assigns
  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "key", token) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}
      {:error, _error} ->
        :error
    end
  end

  def id(_socket), do: nil
end
