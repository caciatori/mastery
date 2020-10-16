defmodule Mastery.ResponseTest do
  use ExUnit.Case
  use QuizBuilders

  describe "a right and wrong reponse" do
    setup [:right, :wrong]

    test "given answers check if their result", %{right: right, wrong: wrong} do
      assert right.correct
      refute wrong.correct
    end

    test "given a right answer check the timestamp", %{right: response} do
      assert %DateTime{} = response.timestamp
      assert response.timestamp < DateTime.utc_now()
    end
  end

  defp right(context) do
    {:ok, Map.put(context, :right, response("3"))}
  end

  defp wrong(context) do
    {:ok, Map.put(context, :wrong, response("2"))}
  end

  defp quiz() do
    fields = template_fields(generators: %{left: [1], right: [2]})

    build(:quiz)
    |> Quiz.add_template(fields)
    |> Quiz.select_question()
  end

  defp response(answer) do
    Response.new(quiz(), "mathy@example.com", answer)
  end
end
