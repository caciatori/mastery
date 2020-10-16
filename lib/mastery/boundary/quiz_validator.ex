defmodule Mastery.Boundary.QuizValidator do
  import Mastery.Boundary.Validator

  def errors(fields) when is_map(fields) do
    []
    |> require(fields, :title, &validate_title/1)
    |> optional(fields, :mastery, &validate_mastery/1)
  end

  def errors(_fields), do: [{nil, "A map of fields is required"}]

  defp validate_title(title) when is_binary(title) do
    check(String.match?(title, ~r{\S}), {:error, "can't be blank"})
  end

  defp validate_title(_title), do: {:error, "must be a string"}

  defp validate_mastery(mastery) when is_integer(mastery) do
    check(mastery > 0, {:error, "must be greater than zero"})
  end

  defp validate_mastery(_mastery), do: {:error, "must be an integer"}
end
