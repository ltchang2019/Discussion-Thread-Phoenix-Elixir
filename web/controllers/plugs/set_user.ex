defmodule Discuss.Plugs.SetUser do
    import Plug.Conn
    import Phoenix.Controller

    alias Discuss.Repo
    alias Discuss.User

    # Plug: set_user
    # ______________
    #   - gets user_id from session
    #   - if id exists and exists in users repo, then session id set to id
    #   - if id doesn't exist in session, then id is set to nil
    
    def init(_params) do
    end

    def call(conn, _params) do
        user_id = get_session(conn, :user_id)

        cond do 
            user = user_id && Repo.get(User, user_id) ->
                assign(conn, :user, user)
            true ->
                assign(conn, :user, nil)
        end
    end
end