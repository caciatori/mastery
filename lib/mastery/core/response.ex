defmodule Mastery.Core.Response do
  defstruct ~w[quiz_title template_name to email answer correct timestamp]a

  def new(quiz, email, answer) do
    %{current_question: %{template: template} = question} = quiz

    %__MODULE__{
      quiz_title: quiz.title,
      template_name: template.name,
      to: email,
      answer: answer,
      correct: template.checker.(question.substitutions, answer),
      timestamp: DateTime.utc_now()
    }
  end
end
