defmodule Mastery.Application do
  @moduledoc false
  use Application

  alias Mastery.Boundary.QuizManager

  def start(_type, _args) do
    IO.puts("Starting Mastery")

    children = [
      {QuizManager, [name: QuizManager]},
      {
        Registry,
        [name: Mastery.Registry.QuizSession, keys: :unique]
      },
      {
        DynamicSupervisor,
        [name: Mastery.Supervisor.QuizSession, strategy: :one_for_one]
      }
    ]

    opts = [strategy: :one_for_one, name: Mastery.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
