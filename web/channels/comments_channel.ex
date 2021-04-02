defmodule Discuss.CommentsChannel do
    use Discuss.Web, :channel

    alias Discuss.{Topic, Comment}

    def join("comments:" <> topic_id, _auth_message, socket) do
        topic_id = String.to_integer topic_id

        topic = Topic
            |> Repo.get(topic_id)
            |> Repo.preload(comments: [:user])

        { :ok, %{ comments: topic.comments }, assign(socket, :topic, topic) }
    end

    def handle_in(name, %{ "comment" => comment }, socket) do
        topic = socket.assigns.topic
        user_id = socket.assigns.user_id

        changeset = topic
        |> build_assoc(:comments, user_id: user_id)
        |> Comment.changeset(%{ content: comment })

        case Repo.insert(changeset) do
            {:ok, comment_row} ->
                broadcast!(socket, "comments:#{topic.id}:new", %{
                    comment: comment_row
                })

                { :reply, :ok, socket }
            {:error, _reason} ->
                {:reply, {:error, %{errors: changeset} }, socket}
        end
    end
end