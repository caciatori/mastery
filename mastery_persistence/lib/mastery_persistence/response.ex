defmodule MasteryPersistence.Response do
  @moduledoc false
  
  use Ecto.Changeset

  import Ecto.Changeset

  @mastery_fields ~w(quiz_title template_name to email answer correct)a
  @timestamp_fields ~w(inserted_at updated_at)a

  schema "responses" do
    field(:quiz_title, :string)
    field(:template_name, :string)
    field(:to, :string)
    field(:email, :string)
    field(:answer, :string)
    field(:correct, :boolean)

    timestamps()
  end

  def record_changeset(fields) do
    %__MODULE__{}
    |> change(fields, @mastery_fields ++ @timestamp_fields)
    |> validate_required(@mastery_fields ++ @timestamp_fields)
  end
end
