defmodule Lector do
  @moduledoc """
  Se encarga únicamente de leer un archivo de texto y convertir sus líneas.
  Recibe la función convertidora (la de Ciudad o la de Movimiento).
  -version 1.0
  -autor: Daniel Gil
  -fecha: 2026-11-08
  """

  @doc """
  Lee el archivo y retorna {:ok, %{registros: lista, rechazados: cantidad}}
  o {:error, motivo} si el archivo no se puede leer.
  """
  def leer(ruta, convertidor) do
    case File.read(ruta) do
      {:ok, contenido} ->
        contenido
        |> String.split("\n")
        |> Enum.map(&String.trim/1)
        |> Enum.reject(fn linea -> linea == "" end)
        |> Enum.map(convertidor)
        |> armar_resultado()

      {:error, motivo} ->
        {:error, motivo}
    end
  end

  defp armar_resultado(resultados) do
    registros =
      resultados
      |> Enum.filter(fn {estado, _} -> estado == :ok end)
      |> Enum.map(fn {_estado, registro} -> registro end)

    rechazados = Enum.count(resultados, fn {estado, _} -> estado == :error end)

    {:ok, %{registros: registros, rechazados: rechazados}}
  end
end
