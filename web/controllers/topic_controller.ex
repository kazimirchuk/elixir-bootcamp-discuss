defmodule Discuss.TopicController do
    use Discuss.Web, :controller

    alias Discuss.Topic

    plug Discuss.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
    plug :check_topic_owner when action in [:update, :edit, :delete]

    def check_topic_owner(conn, _init_result) do
        %{ params: %{ "topic_id" => topic_id } } = conn

        topic_owner_id = Repo.get(Topic, topic_id).user_id

        if topic_owner_id && topic_owner_id == conn.assigns.user.id do
            conn
        else
            conn
            |> put_flash(:error, "Not allowed!")
            |> redirect(to: topic_path(conn, :index))
            |> halt()
        end
    end

    def new(conn, _params) do
        changeset = Topic.changeset(%Topic{}, %{})

        render conn, "new.html", changeset: changeset
    end

    def edit(conn, %{"topic_id" => id }) do
        topic = Repo.get(Topic, id)
        changeset = Topic.changeset(topic)

        render conn, "edit.html", changeset: changeset, topic: topic
    end

    def show(conn, %{"topic_id" => id }) do
        topic = Repo.get!(Topic, id)

        render conn, "show.html", topic: topic
    end

    def update(conn, %{"topic" => topic_changes, "topic_id" => id}) do
        topic = Repo.get(Topic, id)
        changeset = Topic.changeset(topic, topic_changes)

        case Repo.update(changeset) do
            { :ok, topic_row } ->
                conn
                |> put_flash(:info, "Topic successfully updated!")
                |> redirect(to: topic_path(conn, :edit, id))
            { :error, changeset } ->
                render conn, "edit.html", changeset: changeset, topic: topic
        end
    end

    def delete(conn, %{"topic_id" => id}) do
        Repo.get!(Topic, id) |> Repo.delete!

        conn
        |> put_flash(:info, "Topic deleted!")
        |> redirect(to: topic_path(conn, :index))
    end

    def create(conn, %{"topic" => topic}) do
        changeset = conn.assigns.user
        |> build_assoc(:topics)
        |> Topic.changeset(topic)

        case Repo.insert(changeset) do
            { :ok, _topic_row } ->
                conn
                |> put_flash(:info, "Topic successfully created!")
                |> redirect(to: topic_path(conn, :index))
            { :error, changeset } ->
                render conn, "new.html", changeset: changeset
        end
    end

    def index(conn, _params) do
        topics = Repo.all(Topic)

        render conn, "index.html", topics: topics
    end
end
