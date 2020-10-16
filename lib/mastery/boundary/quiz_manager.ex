defmodule Mastery.Boundary.QuizManager do
  alias Mastery.Core.Quiz
  use GenServer

  def init(quizzes) when is_map(quizzes), do: {:ok, quizzes}

  def init(_quizzes), do: {:error, "Quizzes must be a map"}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def handle_call({:build_quiz, fields}, _from, quizzes) do
    quiz = Quiz.new(fields)
    {:reply, :ok, Map.put(quizzes, quiz.title, quiz)}
  end

  def handle_call({:add_template, title, fields}, _from, quizzes) do
    {:reply, :ok, Map.update!(quizzes, title, &Quiz.add_template(&1, fields))}
  end

  def handle_call({:lookup_quiz_by_title, title}, _from, quizzes) do
    {:reply, quizzes[title], quizzes}
  end

  def build_quiz(manager \\ __MODULE__, quiz_fields) do
    GenServer.call(manager, {:build_quiz, quiz_fields})
  end

  def add_template(manager \\ __MODULE__, quiz_title, template_fields) do
    GenServer.call(manager, {:add_template, quiz_title, template_fields})
  end

  def lookup_quiz_by_title(manager \\ __MODULE__, quiz_title) do
    GenServer.call(manager, {:lookup_quiz_by_title, quiz_title})
  end
end
