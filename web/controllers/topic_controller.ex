defmodule Discuss.TopicController do
  use Discuss.Web, :controller
  plug Discuss.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
  plug :check_owner when action in [:edit, :update, :delete]

  alias Discuss.Topic

  # Function: index
  # _______________
  #   - renders index.html topics page
  def index(conn, _params) do
    topics = Repo.all(Topic)
    render conn, "index.html", topics: topics
  end

  # Function: new
  # ______________
  #   - called by get '/topics/new' route (when user clicks on add button on index page)
  #   - creates empty changeset and passes it into render, which renders new.html file (the form)
  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{}, %{})
    render conn, "new.html", changeset: changeset
  end

  # Function: create
  # ________________
  #   - called by post '/' route (default home page)
  #   - gets topic params from changeset sent by new.html form
  #   - builds association between logged in user and new topic and builds changeset for new topic
  #   - inserts changeset into database and redirects to homepage on success
  def create(conn, %{"topic" => topic} = params) do
    changeset = conn.assigns[:user]
    |> build_assoc(:topics)
    |> Topic.changeset(topic)

    case Repo.insert(changeset) do
      {:ok, _topic} -> 
        conn
        |> put_flash(:info, "Topic Created")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} -> 
        render conn, "new.html", changeset: changeset
    end
  end

  # Function: edit
  # ______________
  #   - called by get "/topics/:id/edit" route (from edit buttons which also send id parameter)
  #   - renders edit.html page, passing in topic id and topic's changeset from repo
  def edit(conn, %{"id" => topic_id} = params) do
    topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(topic)
    
    render conn, "edit.html", changeset: changeset, topic: topic
  end

  # Function: update
  # ________________
  #   - called by put "/topics/:id" route (from edit.html form)
  #   - gets changeset and topic id from edit.html form and updates repo using two params
  #   - redirects to index.html page
  def update(conn, %{"id" => topic_id, "topic" => new_topic}) do
    old_topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(old_topic, new_topic)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Updated")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset, topic: old_topic
    end
  end

  # Function: delete
  # ________________
  #   - called by delete "topics/:id" route (from index.html delete button which stores topic id)
  #   - gets topic struct from repo and deletes it
  def delete(conn, %{"id" => topic_id}) do
    Repo.get!(Topic, topic_id) |> Repo.delete!

    conn
    |> put_flash(:info, "Topic Deleted")
    |> redirect(to: topic_path(conn, :index))
  end

  # Function: show
  # _______________
  #   - called from "/topics/:id/show" when user clicks topic's link
  #   - gets id from params, gets topic with given id from database, then renders show.html page
  #     passing in that topic (show.html calls createSocket)
  def show(conn, %{"id" => topic_id} = params) do
    topic = Repo.get!(Topic, topic_id)
    render conn, "show.html", topic: topic
  end

  # Function Plug: check_owner
  # __________________________
  #   - if user_id of topic matches logged in user_id, do nothing
  #   - else, redirect to home page and display error (protection)
  def check_owner(conn, _params) do
    %{params: %{"id" => topic_id}} = conn

    if Repo.get(Topic, topic_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "You don't have access to this topic")
      |> redirect(to: topic_path(conn, :index))
      |> halt()
    end
  end
end
