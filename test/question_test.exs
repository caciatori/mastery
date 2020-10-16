defmodule Mastery.QuestionTest do
  use ExUnit.Case
  use QuizBuilders

  test "building chooses substitutions" do
    question = simple_question_addition()

    assert question.substitutions == [left: 1, right: 2]
  end

  test "building creates a question text" do
    question = simple_question_addition()

    assert question.asked == "1 + 2"
  end

  test "functions generators are called" do
    generators = addition_generator(fn -> 42 end, [0])
    %{substitutions: substitutions} = build(:question, generators: generators)

    assert Keyword.fetch!(substitutions, :left) == generators.left.()
  end

  defp simple_question_addition do
    generators = addition_generator([1], [2])
    build(:question, generators: generators)
  end
end
