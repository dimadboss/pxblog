defmodule Pxblog.ApplyParams do
  def do_apply(module_name, params) do
    case module_name.from(params) do
      %_{valid?: true} = changeset ->
        {:ok, Params.to_map(changeset)}

      error_changeset ->
        {:error, error_changeset}
    end
  end
end
