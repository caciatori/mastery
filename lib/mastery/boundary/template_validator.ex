defmodule Mastery.Boundary.TemplateValidator do
  import Mastery.Boundary.Validator

  def errors(fields) when is_list(fields) do
    fields = Map.new(fields)

    []
    |> require(fields, :name, &validate_atom/1)
    |> require(fields, :name, &validate_atom/1)
    |> optional(fields, :instructions, &validate_instructions/1)
    |> require(fields, :raw, &validate_raw/1)
    |> require(fields, :generators, &validate_generators/1)
    |> require(fields, :checker, &validate_checker/1)
  end

  defp validate_atom(value) when is_atom(value), do: :ok
  defp validate_atom(_value), do: {:error, "must be an atom"}

  defp validate_instructions(instruction) when is_binary(instruction), do: :ok
  defp validate_instructions(_instruction), do: {:error, "must be a string"}

  defp validate_raw(raw) when is_binary(raw) do
    check(String.match?(raw, ~r{\S}), {:error, "can't be blank"})
  end

  defp validate_raw(_raw), do: {:error, "must be a string"}

  defp validate_generators(generators) when is_map(generators) do
    generators
    |> Enum.map(&validate_generator/1)
    |> Enum.reject(&(&1 == :ok))
    |> case do
      [] ->
        :ok

      errors ->
        {:errors, errors}
    end
  end

  defp validate_generators(_generators), do: {:error, "must be a map"}

  defp validate_generator({name, generator})
       when is_atom(name) and is_list(generator),
       do: check(generator != [], {:error, "can't be blank"})

  defp validate_generator({name, generator})
       when is_atom(name) and is_function(generator, 0),
       do: :ok

  defp validate_generator(_generator),
    do: {:error, "must be a string to list or fuction pair"}

  defp validate_checker(checker) when is_function(checker, 2), do: :ok
  defp validate_checker(_checker), do: {:error, "must be an arity 2 function"}
end
