# Parcial 2 - Programación 3: Observatorio Sismológico (Elixir)

Aplicación en Elixir que genera un reporte de sismos por ciudad a partir de dos archivos de texto
(`ciudades.txt` y `movimientos.txt`, campos separados por `@`).

- **Punto 1:** reporte local, leyendo los archivos con procesos concurrentes.
- **Punto 2:** el mismo reporte consultado desde un nodo cliente a un nodo servidor.

## Requisitos

- Elixir instalado (se comprueba con `elixir --version`).
- No se necesitan dependencias externas.

## Estructura

```
parcial-2-elixir/
├── README.md
├── punto-1/
│   ├── sismos.exs         (programa principal)
│   ├── coordinador.exs    (procesos: spawn, send, receive)
│   ├── lector.exs         (lectura de archivos)
│   ├── reporte.exs        (cálculo recursivo y texto del reporte)
│   ├── ciudad.exs         (struct Ciudad y validación)
│   ├── movimiento.exs     (struct Movimiento y validación)
│   ├── util.ex
│   └── resources/
│       ├── ciudades.txt
│       └── movimientos.txt
└── punto-2/
    ├── nodo-cliente/
    │   ├── cliente.exs
    │   └── util.ex
    └── nodo-servidor/
        ├── servidor.exs
        ├── (copias de coordinador, lector, reporte, ciudad, movimiento y util)
        └── resources/
            ├── ciudades.txt
            └── movimientos.txt
```

## Punto 1 - Reporte local

Ejecutar **desde la carpeta `punto-1`**:

```
cd parcial-2-elixir/punto-1
elixir sismos.exs
```

- Archivos de entrada: `punto-1/resources/ciudades.txt` y `punto-1/resources/movimientos.txt`.
- El reporte se muestra en consola y se guarda en `punto-1/resources/reporte_sismos.txt`
  (cada ejecución exitosa reemplaza el contenido anterior).
- Si alguno de los archivos de entrada no se puede leer, se indica cuál falló y se conserva el reporte anterior.

## Punto 2 - Consulta entre nodos

Se usan **dos terminales**. Primero se inicia el servidor y luego el cliente.
Los nombres de los nodos son `servidor@127.0.0.1` y `cliente@127.0.0.1`,
y ambos usan la **misma cookie**: `parcial_sismos` (se configura con `--cookie`).

**Terminal 1 - Servidor** (desde la carpeta `punto-2/nodo-servidor`):

```
cd parcial-2-elixir/punto-2/nodo-servidor
elixir --name servidor@127.0.0.1 --cookie parcial_sismos servidor.exs
```

Debe mostrar: `Servidor listo en el nodo servidor@127.0.0.1. Esperando solicitudes...`
y se queda esperando (no hay que cerrarlo).

**Terminal 2 - Cliente** (desde la carpeta `punto-2/nodo-cliente`):

```
cd parcial-2-elixir/punto-2/nodo-cliente
elixir --name cliente@127.0.0.1 --cookie parcial_sismos cliente.exs
```

El servidor lee `punto-2/nodo-servidor/resources/ciudades.txt` y `movimientos.txt` en cada consulta.

## Verificación del punto 2

El cliente envía, en este orden, las siguientes solicitudes:

| Solicitud | Identificador usado | Qué se verifica |
|---|---|---|
| `{:reporte_ciudad, "C01"}` | C01 (Armenia) | Ciudad con movimientos |
| `{:reporte_ciudad, "C03"}` | C03 (Circasia) | Ciudad sin movimientos |
| `{:reporte_ciudad, "C99"}` | C99 | Ciudad inexistente: «La ciudad no está registrada» |
| `:reporte_general` | - | Reporte de todas las ciudades y registros rechazados |
| `:fin` | - | El servidor confirma con `:fin` y el cliente termina |

**Segunda ejecución:** sin cerrar el servidor, volver a correr en la Terminal 2 el mismo comando del cliente:

```
elixir --name cliente@127.0.0.1 --cookie parcial_sismos cliente.exs
```

Debe mostrar de nuevo las cuatro respuestas en el mismo orden y terminar al recibir `:fin`,
lo que comprueba que el servidor sigue atendiendo solicitudes.

Si se ejecuta el cliente sin el servidor activo, informa el error de conexión y finaliza.

## Reflexión sobre el uso de inteligencia artificial

(Ver el documento adjunto a la entrega.)
