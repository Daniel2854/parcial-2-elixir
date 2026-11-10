defmodule Reporte do
  @moduledoc """
  Se encarga únicamente del cálculo y del texto del reporte.
  No lee archivos ni crea procesos.
  -version 1.0
  -autor: Daniel Gil
  -fecha: 2026-11-09
  """

  @doc """
  Genera el reporte de todas las ciudades válidas, con los registros rechazados por archivo.
  """
  def generar_reporte_general(datos) do
    ciudades_texto =
      datos.ciudades
      |> Enum.map(fn ciudad -> texto_ciudad(ciudad, datos.movimientos) end)
      |> Enum.join("\n\n")

    [
      "===== REPORTE DE SISMOS POR CIUDAD =====",
      ciudades_texto,
      "===== REGISTROS RECHAZADOS =====",
      "ciudades.txt: #{datos.rechazados_ciudades}\nmovimientos.txt: #{datos.rechazados_movimientos}"
    ]
    |> Enum.join("\n\n")
  end

  @doc """
  Genera el reporte de una sola ciudad, o un aviso si el identificador no existe.
  """
  def generar_reporte_ciudad(datos, id_ciudad) do
    case Enum.find(datos.ciudades, fn ciudad -> ciudad.id == id_ciudad end) do
      nil -> "La ciudad no está registrada"
      ciudad -> texto_ciudad(ciudad, datos.movimientos)
    end
  end

  # Arma el texto de una ciudad con sus movimientos y estadísticas
  defp texto_ciudad(ciudad, todos_los_movimientos) do
    movimientos =
      todos_los_movimientos
      |> Enum.filter(fn movimiento -> movimiento.id_ciudad == ciudad.id end)

    {cantidad, mayor, suma} = resumir(movimientos)

    [
      "Ciudad: #{ciudad.nombre}",
      "Habitantes: #{ciudad.habitantes}",
      "Movimientos:",
      texto_detalle(movimientos),
      "Total de movimientos: #{cantidad}",
      "Movimiento de mayor magnitud: #{texto_mayor(mayor)}",
      "Profundidad promedio: #{texto_promedio(suma, cantidad)}"
    ]
    |> Enum.join("\n")
  end

  @doc """
  Recorre la lista UNA sola vez y retorna {cantidad, movimiento_mayor, suma_profundidades}.
  """
  def resumir(movimientos) do
    resumir(movimientos, 0, nil, 0.0)
  end

  # Caso base: ya no quedan movimientos, se entregan los acumuladores
  defp resumir([], cantidad, mayor, suma) do
    {cantidad, mayor, suma}
  end

  # Caso recursivo: se procesa la cabeza y se sigue con el resto de la lista
  defp resumir([movimiento | resto], cantidad, mayor, suma) do
    resumir(
      resto,
      cantidad + 1,
      elegir_mayor(mayor, movimiento),
      suma + movimiento.profundidad
    )
  end

  # Si es el primero, es el mayor. Si empatan, se queda el que apareció antes.
  defp elegir_mayor(nil, movimiento), do: movimiento

  defp elegir_mayor(mayor, movimiento) do
    if movimiento.magnitud > mayor.magnitud do
      movimiento
    else
      mayor
    end
  end

  defp texto_detalle([]) do
    "  Sin movimientos registrados"
  end

  defp texto_detalle(movimientos) do
    movimientos
    |> Enum.map(fn m ->
      "  - #{m.codigo} | Inicio: #{m.hora_inicio} | Final: #{m.hora_final} | Magnitud: #{m.magnitud} | Profundidad: #{m.profundidad} km"
    end)
    |> Enum.join("\n")
  end

  defp texto_mayor(nil), do: "No aplica"
  defp texto_mayor(movimiento), do: "#{movimiento.codigo} · #{movimiento.magnitud}"

  defp texto_promedio(_suma, 0), do: "No aplica"

  defp texto_promedio(suma, cantidad) do
    "#{:erlang.float_to_binary(suma / cantidad, decimals: 2)} km"
  end
end
