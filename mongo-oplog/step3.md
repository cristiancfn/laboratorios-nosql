### Fase 3: Simulacro de Split-Brain (Cerebro Dividido)

Vamos a simular un desastre grave de red. Pausaremos el Nodo 2 (el secundario).

```bash
docker pause ecorutas-nodo2
```{{execute}}

El Nodo 1 sigue siendo Primario porque cuenta con el voto del Árbitro (2 de 3 votos = Mayoría). Simularemos que el Nodo 1 recibe un dato, pero **no puede enviarlo al Nodo 2** porque está pausado (aislado):

```bash
docker exec -i ecorutas-nodo1 mongosh --port 27017 --eval 'db.getSiblingDB("ecorutas_db").telemetria.insertOne({vehiculo_id: "FANTASMA", nota: "Dato Huérfano. Quedará aislado."})'
```{{execute}}

Ahora, ¡Desastre! El Nodo 1 sufre un corte de energía súbito:

```bash
docker kill ecorutas-nodo1
```{{execute}}

Al mismo tiempo, la red del Nodo 2 se restablece:

```bash
docker unpause ecorutas-nodo2
```{{execute}}

Demos 5 segundos para que el clúster se dé cuenta y elija al Nodo 2 como nuevo Primario.
En esta nueva realidad, el camión reporta un dato distinto al Nodo 2:

```bash
sleep 5 && docker exec -i ecorutas-nodo2 mongosh --port 27018 --eval 'db.getSiblingDB("ecorutas_db").telemetria.insertOne({vehiculo_id: "REAL", nota: "La nueva línea temporal correcta."})'
```{{execute}}

**El conflicto:** El Nodo 1 guardó el dato "FANTASMA". El Nodo 2 guardó el dato "REAL". 
Reconectemos el Nodo 1 a la red para ver qué hace MongoDB ante esta divergencia:

```bash
docker start ecorutas-nodo1
```{{execute}}