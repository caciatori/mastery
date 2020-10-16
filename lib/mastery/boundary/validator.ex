defmodule Mastery.Boundary.Validator do
  def check(true = _valid, _message), do: :ok
  def check(false = _valid, message), do: message

  def require(errors, fields, field_name, validator) do
    present? = Map.has_key?(fields, field_name)
    check_required_field(present?, fields, errors, field_name, validator)
  end

  def optional(errors, fields, field_name, validator) do
    if Map.has_key?(fields, field_name),
      do: require(errors, fields, field_name, validator),
      else: errors
  end

  defp check_required_field(present?, fields, errors, field_name, fun)

  defp check_required_field(true, fields, errors, field_name, fun) do
    fields
    |> Map.fetch!(field_name)
    |> fun.()
    |> check_field(errors, field_name)
  end

  defp check_required_field(false, _fields, errors, field_name, _fun) do
    errors ++ [{field_name, "is required"}]
  end

  defp check_field(:ok, _errors, _field_name), do: :ok

  defp check_field({:error, message}, errors, field_name) do
    errors ++ [{field_name, message}]
  end

  defp check_field({:errors, message}, errors, field_name) do
    errors ++ Enum.map(message, &{field_name, &1})
  end
end
