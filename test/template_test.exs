defmodule TemplateTest do
  use ExUnit.Case
  use QuizBuilders

  test "compiles the raw template" do
    fields = template_fields()
    template = Template.new(fields)

    assert is_nil(Keyword.get(fields, :compiled))
    refute is_nil(template.compiled)
  end
end
