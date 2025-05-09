defmodule Codebattle.Event do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Codebattle.Event.Stage
  alias Codebattle.Repo

  @type t :: %__MODULE__{}

  @derive {Jason.Encoder,
           only: [
             :description,
             :id,
             :personal_tournament_id,
             :slug,
             :stages,
             :starts_at,
             :ticker_text,
             :title,
             :type
           ]}

  @types ~w(public private)

  schema "events" do
    belongs_to(:creator, Codebattle.User)

    field(:slug, :string)
    field(:type, :string)
    field(:ticker_text, :string)
    field(:title, :string)
    field(:description, :string)
    field(:starts_at, :utc_datetime)
    field(:personal_tournament_id, :integer)

    embeds_many(:stages, Stage, on_replace: :delete)

    timestamps()
  end

  @spec get_stage(t(), String.t()) :: __MODULE__.Stage.t() | nil
  def get_stage(%__MODULE__{stages: stages}, slug) when is_binary(slug) do
    Enum.find(stages, fn stage -> stage.slug == slug end)
  end

  @spec get_all() :: list(t())
  def get_all do
    Repo.all(__MODULE__)
  end

  @spec get_public() :: list(t())
  def get_public do
    __MODULE__
    |> where([e], e.type == "public")
    |> Repo.all()
  end

  @spec get!(String.t()) :: t() | no_return()
  def get!(id) do
    Repo.get!(__MODULE__, id)
  end

  @spec get(String.t()) :: t() | no_return()
  def get(id) do
    Repo.get(__MODULE__, id)
  end

  @spec get_by_slug!(String.t()) :: t() | no_return()
  def get_by_slug!(slug) do
    Repo.get_by!(__MODULE__, slug: String.downcase(slug))
  end

  @spec get_by_slug(String.t()) :: t() | nil
  def get_by_slug(slug) do
    Repo.get_by(__MODULE__, slug: String.downcase(slug))
  end

  @spec create(map()) :: {:ok, t()} | {:error, term()}
  def create(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert()
  end

  @spec update(t(), map()) :: {:ok, t()} | {:error, term()}
  def update(event, params) do
    event
    |> changeset(params)
    |> Repo.update()
  end

  @spec delete(t()) :: {:ok, t()} | {:error, term()}
  def delete(task) do
    Repo.delete(task)
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(clan, attrs \\ %{}) do
    clan
    |> cast(attrs, [:slug, :type, :ticker_text, :title, :description, :creator_id, :starts_at])
    |> cast_embed(:stages, with: &Stage.changeset/2)
    |> validate_length(:slug, min: 2, max: 57)
    |> validate_length(:description, min: 3, max: 10_000)
    |> validate_length(:title, min: 3, max: 250)
    |> validate_inclusion(:type, @types)
    |> unique_constraint(:slug)
  end

  def types, do: @types
end
