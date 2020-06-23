defmodule Discuss.AuthController do
    use Discuss.Web, :controller
    plug Ueberauth 

    alias Discuss.User

    # Function: callback
    # __________________
    #   - receives auth info from conn + params
    #   - creates changeset using params pulled out of auth info object
    #   - sign user in (adds new user if not registered; logs in new/existing user)
    def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
        user_params = %{token: auth.credentials.token, email: auth.info.email, provider: "github"}
        changeset = User.changeset(%User{}, user_params)
        
        signin(conn, changeset)
    end

    # Function: signin
    # ________________
    #   - inserts or updates user entry in database and signs in user
    defp signin(conn, changeset) do
        case insert_or_update_user(changeset) do
            {:ok, user} ->
                IO.inspect(user)
                conn
                |> put_flash(:info, "Welcome!")
                |> put_session(:user_id, user.id)
                |> redirect(to: topic_path(conn, :index))
            {:error, _reason} ->
                conn
                |> put_flash(:error, "Error signing in")
                |> redirect(to: topic_path(conn, :index))
        end
    end

    # Function: signout
    # _________________
    #   - drops info (id) from session and redirects to homepage
    def signout(conn, _params) do
        conn
        |> configure_session(drop: true)
        |> redirect(to: topic_path(conn, :index))
    end

    # Function: insert_or_update_user
    # _______________________________
    #   - attempts to get user struct from repo with matching email
    #   - inserts new user if non-existent and returns ok regardless
    defp insert_or_update_user(changeset) do
        case Repo.get_by(User, email: changeset.changes.email) do
            nil ->
                # also returns {:ok, user} onsuccess
                Repo.insert(changeset) 
            user ->
                {:ok, user}
        end
    end
end