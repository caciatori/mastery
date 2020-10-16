defmodule QuizBuilders do
  defmacro __using__(_options) do
    quote do
      alias Mastery.Core.{Quiz, Response, Template}
      import QuizBuilders, only: :functions
    end
  end

  alias Mastery.Core.{Quiz, Question, Template}

  def template_fields(overrides \\ []) do
    attrs = [
      name: :single_digit_addition,
      category: :addition,
      instructions: "Add the number",
      raw: "<%= @left %> + <%= @right %>",
      generators: addition_generator(single_digit()),
      checker: &addition_checker/2
    ]

    Keyword.merge(attrs, overrides)
  end

  def addition_generator(left, right \\ nil) do
    %{left: left, right: right || left}
  end

  def addition_generator_with_two_digits do
    attrs = [
      name: :double_digit_addition,
      generators: addition_generator(double_digits())
    ]

    template_fields(attrs)
  end

  def single_digit, do: Enum.to_list(0..9)
  def double_digits, do: Enum.to_list(0..99)

  def addition_checker(substitutions, answer) do
    left = Keyword.fetch!(substitutions, :left)
    right = Keyword.fetch!(substitutions, :right)

    to_string(left + right) == String.trim(answer)
  end

  def quiz_fields(overrides \\ []) do
    attrs = [title: "Simple Arithmetic"]
    Keyword.merge(attrs, overrides)
  end

  def build(struct_name, overrides \\ [])

  def build(:quiz, overrides) do
    overrides
    |> quiz_fields()
    |> Quiz.new()
  end

  def build(:quiz_with_two_templates, overrides) do
    :quiz
    |> build(overrides)
    |> Quiz.add_template(template_fields())
    |> Quiz.add_template(addition_generator_with_two_digits())
  end

  def build(:question, overrides) do
    overrides
    |> template_fields()
    |> Template.new()
    |> Question.new()
  end
end
