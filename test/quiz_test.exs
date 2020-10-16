defmodule Mastery.QuizTest do
  use ExUnit.Case
  use QuizBuilders

  describe "when quiz has two templates" do
    setup [:quiz]

    test "the next question is randomly selected", %{quiz: quiz} do
      %{
        current_question: %{
          template: first_template
        }
      } = Quiz.select_question(quiz)

      other_question = eventualy_pick_other_template(quiz, first_template)
      assert first_template != other_question
    end

    test "templates are unique until cycle repeats", %{quiz: quiz} do
      first_quiz = Quiz.select_question(quiz)
      second_quiz = Quiz.select_question(first_quiz)
      reset_quiz = Quiz.select_question(second_quiz)

      assert template(first_quiz) != template(second_quiz)

      assert template(reset_quiz) in [
               template(first_quiz),
               template(second_quiz)
             ]
    end
  end

  describe "a quiz that always add one an two" do
    setup [:quiz_always_adds_one_or_two]

    test "a wrong answer resets mastery", %{quiz: quiz} do
      quiz
      |> Quiz.select_question()
      |> assert_more_questions()
      |> right_answer()
      |> Quiz.select_question()
      |> assert_more_questions()
      |> wrong_answer()
      |> Quiz.select_question()
      |> assert_more_questions()
      |> right_answer()
      |> Quiz.select_question()
      |> assert_more_questions()
      |> right_answer()
      |> Quiz.select_question()
      |> refute_more_questions()
    end
  end

  defp assert_more_questions(quiz) do
    refute is_nil(quiz)
    quiz
  end

  defp refute_more_questions(quiz) do
    assert is_nil(quiz)
    quiz
  end

  defp quiz(context) do
    {:ok, Map.put(context, :quiz, build(:quiz_with_two_templates))}
  end

  defp quiz_always_adds_one_or_two(context) do
    fields = template_fields(generators: addition_generator([1], [2]))

    quiz =
      :quiz
      |> build(mastery: 2)
      |> Quiz.add_template(fields)

    {:ok, Map.put(context, :quiz, quiz)}
  end

  defp eventualy_pick_other_template(quiz, template) do
    Stream.repeatedly(fn ->
      quiz
      |> Quiz.select_question()
      |> template()
    end)
    |> Enum.find(&(&1 != template))
  end

  defp template(quiz) do
    %{current_question: %{template: template}} = quiz
    template
  end

  defp right_answer(quiz), do: answer_question(quiz, "3")
  defp wrong_answer(quiz), do: answer_question(quiz, "wrong")

  defp answer_question(quiz, answer) do
    response = Response.new(quiz, "mathy@example.com", answer)
    Quiz.answer_question(quiz, response)
  end
end
