defmodule Movimiento do
  @moduledoc """
  Representa un movimiento sísmico y valida cada línea del archivo movimientos.txt.
  Formato de la línea: codigo@idCiudad@horaInicio@horaFinal@magnitud@profundidad
  -version 1.0
  -autor: Daniel Gil
  -fecha: 2026-11-08
  """

  defstruct codigo: "", id_ciudad: "", hora_inicio: "", hora_final: "", magnitud: 0.0, profundidad: 0.0

  @doc """
  Convierte una línea en un movimiento.
  Retorna {:ok, %Movimiento{}} o {:error, motivo} si la línea se debe rechazar.
  No valida el idCiudad contra el catálogo: eso lo hace el coordinador.
  """
  def convertir_linea(linea) do
    case String.split(linea, "@") do
      [codigo, id_ciudad, hora_inicio, hora_final, magnitud, profundidad] ->
        crear_movimiento(
          String.trim(codigo),
          String.trim(id_ciudad),
          String.trim(hora_inicio),
          String.trim(hora_final),
          convertir_decimal(String.trim(magnitud)),
          convertir_decimal(String.trim(profundidad))
        )

      _ ->
        {:error, :formato_invalido}
    end
  end

  defp crear_movimiento(codigo, id_ciudad, hora_inicio, hora_final, magnitud, profundidad) do
    cond do
      codigo == "" or id_ciudad == "" -> {:error, :campo_vacio}
      not hora_valida?(hora_inicio) or not hora_valida?(hora_final) -> {:error, :hora_invalida}
      magnitud == :error or profundidad == :error -> {:error, :numero_invalido}
      profundidad < 0 -> {:error, :profundidad_negativa}
      true ->
        {:ok, %Movimiento{
          codigo: codigo,
          id_ciudad: id_ciudad,
          hora_inicio: hora_inicio,
          hora_final: hora_final,
          magnitud: magnitud,
          profundidad: profundidad
        }}
    end
  end

  # Si el texto no es un decimal completo (ej. "3.4abc"), retorna :error
  defp convertir_decimal(texto) do
    case Float.parse(texto) do
      {numero, ""} -> numero
      _ -> :error
    end
  end

  # La hora debe tener formato HH:MM:SS y ser una hora real del día
  defp hora_valida?(hora) do
    String.length(hora) == 8 and match?({:ok, _}, Time.from_iso8601(hora))
  end
end
