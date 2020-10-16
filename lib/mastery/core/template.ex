defmodule Mastery.Core.Template do
  defstruct ~w[name category instructions raw compiled generators checker]a

  def new(fields) do
    raw = Keyword.fetch!(fields, :raw)
    rawed_question = EEx.compile_string(raw)

    struct!(__MODULE__, Keyword.put(fields, :compiled, rawed_question))
  end
end
