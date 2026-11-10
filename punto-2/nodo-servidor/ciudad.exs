defmodule Ciudad do
  @moduledoc """
  Representa una ciudad del catálogo y valida cada línea del archivo ciudades.txt.
  Formato de la línea: idCiudad@nombre@numeroHabitantes
  -version 1.0
  -autor: Daniel Gil
  -fecha: 2026-11-08
  """

  defstruct id: "", nombre: "", habitantes: 0

  @doc """
  Convierte una línea en una ciudad.
  Retorna {:ok, %Ciudad{}} o {:error, motivo} si la línea se debe rechazar.
  """
  def convertir_linea(linea) do
    case String.split(linea, "@") do
      [id, nombre, habitantes] ->
        crear_ciudad(String.trim(id), String.trim(nombre), String.trim(habitantes))

      _ ->
        {:error, :formato_invalido}
    end
  end

  defp crear_ciudad(id, nombre, habitantes_texto) do
    cond do
      id == "" or nombre == "" -> {:error, :campo_vacio}
      convertir_entero(habitantes_texto) <= 0 -> {:error, :habitantes_invalidos}
      true -> {:ok, %Ciudad{id: id, nombre: nombre, habitantes: convertir_entero(habitantes_texto)}}
    end
  end

  # Si el texto no es un entero completo, retorna 0 (que luego se rechaza)
  defp convertir_entero(texto) do
    case Integer.parse(texto) do
      {numero, ""} -> numero
      _ -> 0
    end
  end
end
