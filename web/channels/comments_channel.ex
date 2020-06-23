defmodule Discuss.CommentsChannel do
    use Discuss.Web, :channel

    alias Discuss.{Topic, Comment}

    # Function: join
    # ______________
    #   - gets topic id from channel name (called by user_socket when matching)
    #   - gets topic with preloaded topic comments and those comments' users
    #   - assigns topic to :topic field in socket.assigns
    def join("comments:" <> topic_id, _params, socket) do
        topic_id = String.to_integer(topic_id)
        topic = Topic
            |> Repo.get(topic_id)
            |> Repo.preload(comments: [:user])

        {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
    end

    # Function: handle_in
    # ___________________
    #   - receives name ("comment:...") and content from button channel.push
    #   - receives topic and user_id from socket assigns object and builds comment changeset with it 
    #     (manually adds user_id association)
    #   - inserts changeset into repo/database and broadcasts change to channel onsuccess
    def handle_in(name, %{"content" => content}, socket) do
        topic = socket.assigns.topic
        user_id = socket.assigns.user_id

        changeset = topic
            |> build_assoc(:comments, user_id: user_id)
            |> Comment.changeset(%{content: content})

        case Repo.insert(changeset) do 
            {:ok, comment} ->
                broadcast!(socket, "comments:#{socket.assigns.topic.id}:new", %{comment: comment})

                {:reply, :ok, socket}
            {:error, _reason} ->
                {:reply, {:error, %{errors: changeset}}, socket}
        end

        {:reply, :ok, socket}
    end
end