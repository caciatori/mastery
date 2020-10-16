defmodule Mastery.Core.Question do
  alias Mastery.Core.Template

  @type t :: __MODULE__

  defstruct ~w[asked substitutions template]a

  def new(%Template{generators: generators} = template) do
    generators
    |> Enum.map(&build_substitution/1)
    |> evaluate(template)
  end

  defp evaluate(substitutions, template) do
    %__MODULE__{
      asked: compile(template, substitutions),
      substitutions: substitutions,
      template: template
    }
  end

  defp compile(%{compiled: compiled}, substitutions) do
    compiled
    |> Code.eval_quoted(assigns: substitutions)
    |> elem(0)
  end

  defp build_substitution({name, choices_or_generator}) do
    {name, choose(choices_or_generator)}
  end

  defp choose(choices) when is_list(choices), do: Enum.random(choices)
  defp choose(generator) when is_function(generator), do: generator.()
end
