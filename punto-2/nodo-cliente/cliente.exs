Code.require_file("util.ex")

defmodule Cliente do
  @moduledoc """
  Nodo cliente del Observatorio Sismológico.
  Se conecta al nodo servidor, envía las solicitudes en orden y muestra las respuestas.
  -version 1.0
  -autor: Daniel Gil
  -fecha: 2026-11-09
  """

  @nodo_servidor :"servidor@127.0.0.1"

  @doc """
  Función principal que inicia la ejecución del cliente.
  """
  def main do
    Process.register(self(), :servicio_respuesta)

    case Node.connect(@nodo_servidor) do
      true ->
        "Conectado al servidor #{@nodo_servidor}\n"
        |> Util.mostrar_mensaje()

        enviar_solicitudes()
        recibir_respuestas()

      _ ->
        "Error: no se pudo conectar al nodo #{@nodo_servidor}"
        |> Util.mostrar_mensaje()
    end
  end

  # Cada mensaje tiene la forma {destino_respuesta, solicitud}
  defp enviar_solicitudes do
    destino_respuesta = {:servicio_respuesta, node()}

    [
      {:reporte_ciudad, "C01"},
      {:reporte_ciudad, "C03"},
      {:reporte_ciudad, "C99"},
      :reporte_general,
      :fin
    ]
    |> Enum.each(fn solicitud ->
      send({:servicio_sismos, @nodo_servidor}, {destino_respuesta, solicitud})
    end)
  end

  # Recibe y muestra respuestas de forma recursiva hasta recibir :fin
  defp recibir_respuestas do
    receive do
      :fin ->
        "El servidor confirmó el fin de las respuestas."
        |> Util.mostrar_mensaje()

      respuesta ->
        "----------------------------------------"
        |> Util.mostrar_mensaje()

        respuesta
        |> Util.mostrar_mensaje()

        recibir_respuestas()
    end
  end
end

Cliente.main()
