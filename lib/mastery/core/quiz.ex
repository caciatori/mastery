defmodule Mastery.Core.Quiz do
  alias Mastery.Core.{Question, Template, Response}

  @type t :: __MODULE__

  defstruct title: nil,
            mastery: 3,
            templates: %{},
            used: [],
            current_question: nil,
            last_response: nil,
            record: %{},
            mastered: []

  def new(fields) do
    struct!(__MODULE__, fields)
  end

  def add_template(quiz, fields) do
    template = Template.new(fields)

    templates =
      update_in(
        quiz.templates,
        [template.category],
        &add_to_template_or_nil(&1, template)
      )

    %{quiz | templates: templates}
  end

  defp add_to_template_or_nil(nil, template), do: [template]
  defp add_to_template_or_nil(templates, template), do: [template | templates]

  def select_question(%__MODULE__{templates: templates}) when templates == %{}, do: nil

  def select_question(quiz) do
    quiz
    |> pick_current_question()
    |> move_template(:used)
    |> reset_template_cycle()
  end

  defp pick_current_question(quiz) do
    Map.put(quiz, :current_question, select_random_question(quiz))
  end

  defp select_random_question(quiz) do
    quiz.templates
    |> Enum.random()
    |> elem(1)
    |> Enum.random()
    |> Question.new()
  end

  defp move_template(quiz, field) do
    quiz
    |> remove_template_from_category()
    |> add_template_to_field(field)
  end

  defp remove_template_from_category(quiz) do
    template = template(quiz)

    new_category_template =
      quiz.templates
      |> Map.fetch!(template.category)
      |> List.delete(template)

    new_template =
      if new_category_template == [] do
        Map.delete(quiz.templates, template.category)
      else
        Map.put(quiz.templates, template.category, new_category_template)
      end

    Map.put(quiz, :templates, new_template)
  end

  defp template(quiz), do: quiz.current_question.template

  defp add_template_to_field(quiz, field) do
    template = template(quiz)
    list = Map.get(quiz, field)
    Map.put(quiz, field, [template | list])
  end

  defp reset_template_cycle(%{templates: templates} = quiz) when map_size(templates) == 0 do
    %{used: used} = quiz

    %__MODULE__{quiz | used: [], templates: Enum.group_by(used, & &1.category)}
  end

  defp reset_template_cycle(quiz), do: quiz

  def answer_question(quiz, %Response{correct: true} = response) do
    new_quiz =
      quiz
      |> inc_record()
      |> save_response(response)

    maybe_advance(new_quiz, mastered?(new_quiz))
  end

  def answer_question(quiz, %Response{correct: false} = response) do
    quiz
    |> reset_record()
    |> save_response(response)
  end

  def save_response(quiz, response) do
    Map.put(quiz, :last_response, response)
  end

  def mastered?(%{mastery: mastery, record: record} = quiz) do
    score = Map.get(record, template(quiz).name, 0)
    score == mastery
  end

  defp inc_record(%{current_question: question} = quiz) do
    new_record = Map.update(quiz.record, question.template.name, 1, &(&1 + 1))
    Map.put(quiz, :record, new_record)
  end

  defp maybe_advance(quiz, false = _mastered), do: quiz
  defp maybe_advance(quiz, true = _mastered), do: advance(quiz)

  defp advance(quiz) do
    quiz
    |> move_template(:mastered)
    |> reset_record()
    |> reset_used()
  end

  defp reset_record(%{current_question: question} = quiz) do
    Map.put(quiz, :record, Map.delete(quiz.record, question.template.name))
  end

  defp reset_used(%{current_question: question} = quiz) do
    Map.put(quiz, :used, List.delete(quiz.used, question.template))
  end
end
