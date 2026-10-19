# Central de Abastos CDMX --- Documento de diseño del juego

Oct 18, 2026 · \@Alan

## 1. Concepto y la CEDA real en cifras

El juego es un simulador de comercio y conducción: el jugador empieza
como chofer/diablero y crece hasta bodeguero mayorista en la Central de
Abasto (CEDA) de Iztapalapa, el mercado mayorista más grande del mundo.
La meta de diseño es que cada sistema (logística, precios, NPCs,
horarios) reproduzca la operación real a escala.

**Pilares de diseño**

-   **Comprar barato en la madrugada, vender caro antes de que se
    pudra**: el producto pierde valor cada hora (merma).

-   **Conducción pesada creíble**: reversa con tráiler a andén, tráfico
    de miles de unidades, cuota de acceso, pernocta.

-   **Mercado vivo**: miles de NPCs con rutinas (diableros, compradores,
    gritones, policías, tlacoyeras) que reaccionan a la hora del día.

-   **Economía dinámica**: precios por oferta/demanda, temporada y
    eventos (lluvias, bloqueos, heladas).

**La CEDA en cifras (datos de referencia para escalar el mapa)**

  -----------------------------------------------------------------------
  Dato                 Valor                Uso en el juego
  -------------------- -------------------- -----------------------------
  Superficie           327 ha (aprox. 51    Tamaño del mapa jugable
                       veces el Zócalo)     

  Inauguración         22 nov 1982, diseño  Lore, placas, monumentos
                       de Abraham           
                       Zabludovsky          

  Volumen diario       \~30,000 t de        Calibrar flujo total de
                       alimentos            camiones

  Capacidad de         122,000 t            Límite de inventario global
  almacenaje                                

  Vehículos al día     \~52,000             Densidad de tráfico

  Visitantes al día    300,000 a 500,000    Densidad de NPCs (simulados
                                            por LOD)

  Empleos directos     \~70,000 a 90,000    Variedad de oficios NPC

  Unidades económicas  9,400+               Locales, bodegas, tiendas,
                                            puestos

  Bodegas totales      \~2,429              Cada una comprable/rentable
                       (Fideicomiso)        

  Bodegas Frutas y     1,881                Sector principal del juego
  Legumbres                                 

  Bodegas Abarrotes y  338                  Sector secundario
  Víveres                                   

  Medida de bodega     5 m de frente x 20 m Módulo base del level design
                       de fondo             

  Diableros            \~11,000             NPC más abundante
  (cargadores)                              

  Basura diaria        400+ t               Sistema de limpieza / merma

  Horario              24 h, todos los      Ciclo día/noche
                       días; pico en la     
                       madrugada            
  -----------------------------------------------------------------------

Salidas diarias de producto reportadas: unas 770 t de jitomate, 800 t de
fresa, 400 t de plátano y 250 t de naranja; sirven para ponderar qué
productos dominan la demanda en el juego. Fuentes: [Gobierno
CDMX](https://mexicocity.cdmx.gob.mx/venues/central-de-abasto/), [La
Jornada](https://www.jornada.com.mx/2005/05/16/003n1sec.html),
[Chilango](https://www.chilango.com/que-hacer/central-de-abasto-lanza-visitas-guiadas-gratis-cultura-gastronomia/),
[Food & City](https://foodandcity.org/?p=1407).

## 2. Mapa y estructura física

La CEDA es un hexágono alargado con 8 sectores; el corazón del juego son
las naves de Frutas y Legumbres (pasillos I-J a W-X) y el andén de
Subasta y Productores. Las calles siguen letras de norte a sur y las
bodegas se numeran de poniente a oriente, así que la dirección de
cualquier bodega es *Pasillo + Número* (ej. \"I-J 145\"): úsala como
sistema de navegación del juego.

### Los 8 sectores

  ----------------------------------------------------------------------------
  Sector          Tamaño real     Qué se vende          Rol en el juego
  --------------- --------------- --------------------- ----------------------
  Frutas y        1,881 bodegas,  Fruta y verdura a     Zona principal:
  Legumbres       naves I-J a W-X mayoreo               comprar, vender,
                                                        rentar bodega

  Abarrotes y     338 bodegas,    Granos, latas,        Segundo negocio
  Víveres         naves A-B a G-H lácteos, dulces,      desbloqueable
                                  chiles secos          

  Subasta y       10.6 ha,        Venta a pie de camión Primer eslabón: el
  Productores     capacidad 624   por productores       productor vende el
                  tráileres                             camión completo

  Flores y        16 ha, \~3,360  Flor de corte,        Mercado de madrugada,
  Hortalizas      locales         hierbas, nopal,       menudeo
                                  hortaliza de hoja     

  Aves y Cárnicos 3 ha, 111       Pollo, cerdo, res     Sector con cadena fría
                  bodegas + 115                         (opcional)
                  locales                               

  Envases Vacíos  1.7 ha, 359     Cajas de madera,      Compra/venta de
                  lotes           huacales, rejas de    envase, recurso
                                  plástico reparadas    necesario

  Bodegas de      96 bodegas      Transbordo de carga   Misiones logísticas
  Transferencia                   entre camiones        (cross-docking)

  Zona de         5.1 ha, 424     Estacionamiento       Descanso del chofer,
  Pernocta        unidades de     nocturno de camiones  gestión de fatiga
                  hasta 30 t                            
  ----------------------------------------------------------------------------

Además: frigorífico de 2,000 t, planta de transferencia de basura de
2,000 t, 33 rampas helicoidales a estacionamientos en azotea, mercado de
pescados y mariscos (oriente de pasillos M-X), bancos, fondas, iglesia,
policía y la gran planta solar sobre techos.

### Módulo de construcción (level design)

-   **Bodega**: 5 m de frente x 20 m de fondo, cortina metálica, tapanco
    (entrepiso) al fondo, oficina pequeña, báscula.

-   **Nave**: dos hileras de bodegas espalda con espalda; por delante,
    el **pasillo peatonal** (diableros y compradores) y por detrás, el
    **andén de carga** donde los camiones recargan en batería (reversa a
    90°).

-   **Calles de servicio**: anchas, dos sentidos, entre naves; aquí
    ocurre el tráfico pesado y las maniobras.

-   **Accesos**: casetas de cobro perimetrales con plumas; se paga al
    entrar según tipo de vehículo.

-   **Escala recomendada**: modelar 1 nave completa a 1:1 y el resto
    como instancias/LOD. Una nave de Frutas mide del orden de cientos de
    metros de largo; con módulos de 5 m las bodegas se colocan por
    código.

Dato clave de escala: cada pasillo mide alrededor de un kilómetro, según
la coordinación de la CEDA
([Chilango](https://www.chilango.com/noticias/bara-bara-bara-bara-central-de-abasto-tiene-la-canasta-basica-mas-barata-de-cdmx-esto-cuesta/)).
Caminar de I-J a X-Y es un viaje: justifica diablos, triciclos, Cedabús
y viaje rápido.

El mapa oficial por sectores está publicado por la CEDA y reproducido en
[Chilango](https://www.chilango.com/que-hacer/guia-para-comprar-en-la-central-de-abasto-horarios-pasillos-y-todo-lo-que-hay/)
y [El
CEO](https://elceo.com/negocios/cuantas-tiendas-y-bodegas-hay-en-la-central-de-abastos/):
úsalo como plantilla de blockout. Ubicaciones gruesas: frutas y
hortalizas al poniente de A-H, aves y cárnicos al poniente de U-X,
subasta al poniente de K-R, pescados al oriente de M-X.

## 3. Horarios y ciclo de un día real

La CEDA abre 24 h, pero el negocio se decide entre las 22:00 y las
10:00: los camiones llegan de noche, la subasta fija precios desde las
3:00 y a media mañana el mayoreo ya bajó. El reloj del juego debe correr
rápido de día y lento en la madrugada, que es cuando pasa todo.

  -----------------------------------------------------------------------
  Hora         Qué pasa en la CEDA real           Efecto en el juego
  ------------ ---------------------------------- -----------------------
  22:00 a      Empiezan a llegar tráileres y      Fila en casetas;
  01:00        tortons de provincia con la        asignación de andén; el
               mercancía del día siguiente; la    chofer puede dormir
               Zona de Pernocta se llena          (recupera fatiga)

  01:00 a      Descarga masiva en andenes         Minijuego de descarga y
  03:00        traseros; diableros y cargadores   acomodo; contratación
               trabajan a destajo; bodegueros     de cargadores
               revisan calidad y pesan            

  03:00 a      Abre la Subasta: productores       Se genera la tabla de
  04:00        venden a pie de camión, se fijan   precios del día; mejor
               los precios de referencia del día; momento para comprar
               tráfico para entrar                barato por volumen

  04:00 a      Pico de compradores: mercados      Máxima demanda; regateo
  07:00        públicos, tianguis, recauderías,   intenso; pasillos
               restaurantes; Flores y Hortalizas  saturados de diablos
               en su máximo                       

  07:00 a      Siguen compradores medianos; carga Precio estable o
  10:00        de 3.5 t y rabones de salida;      bajando; ventas a
               primeros embotellamientos en       crédito y pedidos
               salidas                            

  10:00 a      Menudeo y visitantes particulares; Precio del perecedero
  14:00        fondas llenas; producto de segunda baja 10 a 30%; venta de
               se remata                          rezaga

  14:00 a      Bodegas cierran cortinas           Contabilidad, renta,
  18:00        progresivamente; administración,   pago de cuotas, mejoras
               bancos, pago a proveedores         de bodega

  18:00 a      Limpieza, recolección de basura    Gestión de merma,
  22:00        (400+ t/día), vigilancia; pocas    preparar pedidos del
               operaciones                        día siguiente, comprar
                                                  a productores por
                                                  teléfono
  -----------------------------------------------------------------------

**Variación semanal y anual (para el sistema de demanda)**

-   Lunes y jueves/viernes: más compra para tianguis y fin de semana;
    domingo con menos operación mayorista.

-   Temporadas pico: Día de Muertos (cempasúchil, calabaza, caña,
    tejocote, naranja), 12 de diciembre y Navidad (tejocote, caña,
    jamaica, ponche), Cuaresma (nopal, chile, pescado), Fiestas Patrias
    (chile poblano, granada, nuez), Rosca de Reyes y febrero (precios
    bajos).

-   Clima: heladas y granizo encarecen jitomate y hortaliza de hoja;
    lluvias fuertes retrasan camiones de la sierra.

Fuentes: [Gobierno
CDMX](https://mexicocity.cdmx.gob.mx/venues/central-de-abasto/), [N+ ---
Subasta](https://www.nmas.com.mx/ciudad-de-mexico/central-de-abasto-de-la-cdmx-subastas-un-espacio-de-venta-a-mayoreo-y-menudeo/),
[Chilango --- 40
años](https://www.chilango.com/agenda/otros/todos-los-caminos-llevan-a-la-central-de-abasto/),
[Food & City](https://foodandcity.org/city-feeds-mexico/).

## 4. Catálogo completo de vehículos

A la CEDA entran unas 52,000 unidades al día, de bicicleta de carga a
full de 66.5 t; el juego necesita 12 clases de vehículo con física,
capacidad y cuota distintas. Los nombres de uso en la CEDA (rabón,
torton, tres y media) se mapean a la clasificación oficial
NOM-012-SCT-2-2017 (C2, C3, T3-S2, T3-S2-R4), que sigue vigente en 2026.
Medidas y capacidades útiles son aproximadas y varían por carrocería.

### Vehículos motorizados de carga

  --------------------------------------------------------------------------------------------------------------------------------
  Clase (jerga)      Clasificación   Ejes /    Largo    Caja aprox.  Carga útil  PBV máx.        Modelos típicos Quién la maneja /
                     NOM-012         llantas   total                 aprox.                      a modelar       uso en la CEDA
                                               aprox.                                                            
  ------------------ --------------- --------- -------- ------------ ----------- --------------- --------------- -----------------
  Full (doble        T3-S2-R4        9 ejes /  \~31 m   2 cajas de   45 a 50 t   66.5 t (75.5 t  Kenworth        Grandes
  remolque)                          34                 40 pies                  diferenciado)   T680/W900,      productores e
                                     llantas                                                     Freightliner    importadores;
                                                                                                 Cascadia,       solo en Subasta y
                                                                                                 International   bodegas de
                                                                                                 LT/ProStar,     transferencia
                                                                                                 Volvo VNL       

  Tráiler 53 pies    T3-S2           5 ejes /  \~22 a   16.15 m (53  22 a 25 t   \~46 t          Mismos          Producto de largo
                                     18        23 m     ft), hasta                               tractos + caja  recorrido:
                                     llantas            \~110 m³                                 seca o          Sinaloa, Sonora,
                                                                                                 refrigerada     Chihuahua,
                                                                                                 (thermo)        Michoacán

  Tráiler 48 pies /  T3-S2           5 ejes    \~20 m   14.6 m;      20 a 25 t   \~46 t          Tractos         Sandía, piña,
  plataforma                                            plataforma                               anteriores +    coco, caña,
                                                        con redilas                              plataforma o    cebolla en costal
                                                        para melón,                              jaula           
                                                        sandía, piña                                             

  Torton (10         C3              3 ejes /  10 a 12  8 a 9 m,     12 a 18 t   27.5 t          International   El \"camión de
  llantas)                           10        m        redilas o                                4400 / 7400,    rancho\":
                                     llantas            caja seca                                Freightliner M2 productor de
                                                                                                 112, Kenworth   Puebla, Edomex,
                                                                                                 T370, Hino 500  Morelos, Hidalgo
                                                                                                 (8x4 raros),    
                                                                                                 Dina antiguos   

  Rabón              C2              2 ejes /  8 a 10 m 6 a 7 m,     6 a 10 t    19 t            International   Bodeguero que
                                     6 llantas          redilas o                                4300,           surte mercados y
                                                        caja seca                                Freightliner M2 tiendas; reparto
                                                                                                 106, Hino 500,  regional
                                                                                                 Isuzu Forward,  
                                                                                                 Mercedes Atego  

  Tres y media (3.5  C2 ligero       2 ejes /  6 a 7 m  4 a 5 m,     3 a 4 t     \~7 t           Ford F-350 /    El vehículo más
  t)                                 6 llantas          redilas de                               F-450 Super     icónico del
                                     (rodada            madera                                   Duty, Chevrolet comprador de
                                     doble)                                                      Silverado 3500, mercado y
                                                                                                 Isuzu ELF 400,  tianguis
                                                                                                 JAC X350,       
                                                                                                 Foton, Nissan   
                                                                                                 Cabstar antiguo 

  Camioneta de 1.5 t Ligero          2 ejes /  5 a 5.3  2.3 a 3 m    1 a 1.5 t   \~3 t           Nissan NP300    Fondas,
  con redilas                        4 llantas m        con estacas                              chasis,         recauderías,
  (\"estaquitas\")                                                                               Chevrolet S10   tianguistas
                                                                                                 Max, Toyota     pequeños
                                                                                                 Hilux chasis,   
                                                                                                 JAC Frison,     
                                                                                                 Isuzu ELF 100   

  Pick-up (sin       Ligero          2 ejes /  \~5.2 m  caja 1.5 a   0.6 a 1 t   \~2.5 t         Nissan NP300    Restauranteros,
  redilas)                           4 llantas          1.8 m                                    pick-up, Ford   compras chicas
                                                                                                 Ranger, VW      
                                                                                                 Saveiro,        
                                                                                                 Chevrolet       
                                                                                                 Tornado         

  Panel / furgoneta  Ligero          2 ejes    \~5 a 6  Cerrada      1 a 1.5 t   \~3.5 t         Nissan Urvan,   Reparto a
                                               m                                                 Ford Transit,   restaurantes y
                                                                                                 Chevrolet       supermercados
                                                                                                 Express, Toyota 
                                                                                                 Hiace           

  Refrigerado        C2/C3/T3-S2     según     según    Caja aislada según base  según base      Cualquiera de   Fresa, berries,
  (thermo)                           base      base     con unidad                               los anteriores  hongos, carne,
                                                        Thermo King                              con thermo      lácteos
                                                        / Carrier                                                

  Auto particular /  Ligero          2 ejes    \~4.5 m  Cajuela      \<0.4 t     ---             Nissan Versa /  Compradores de
  taxi                                                                                           Tsuru antiguo,  menudeo, taxis,
                                                                                                 VW Vento,       apps
                                                                                                 Chevrolet Aveo  

  Cedabús /          Autobús         2 ejes    \~11 m   ---          Pasajeros   ---             Autobús urbano  NPC de transporte
  transporte interno                                                                             de 29 paradas   público interno
  --------------------------------------------------------------------------------------------------------------------------------

### Vehículos sin motor o de patio

  -------------------------------------------------------------------------
  Equipo         Capacidad     Detalle para modelar    Rol en el juego
                 aprox.                                
  -------------- ------------- ----------------------- --------------------
  Diablito de 2  200 a 300 kg  Bastidor tubular,       Primer vehículo del
  ruedas         (5 a 10       llantas neumáticas, se  jugador
                 cajas)        inclina y se empuja     

  Diablo de      500 kg a más  Plataforma de madera o  Diablero experto;
  plataforma /   de 1 t (los   metal, timón para       colisiones con
  carretilla de  diableros     jalar, llantas macizas  peatones
  4 ruedas       llegan a                              
                 mover más de                          
                 una tonelada)                         

  Patín          \~2.5 t       Tarima europea o        Mover tarimas dentro
  hidráulico                   americana               de bodega
  (patito)                                             

  Montacargas    1.5 a 3 t     Gas LP o eléctrico,     Descargar tráiler
                               Toyota / Yale / Hyster  con tarimas en
                                                       bodegas grandes

  Triciclo de    100 a 200 kg  Bicicleta con caja al   Vendedores de
  carga                        frente                  comida, reparto de
                                                       café y tamales

  Carrito de     ---           Contenedor con ruedas   NPC de limpieza
  basura /                                             
  barredora                                            
  -------------------------------------------------------------------------

**Diferencias jugables clave**

-   **Radio de giro y voladizo trasero**: el full y el tráiler necesitan
    maniobras de varios cortes; el rabón gira en una calle de servicio.

-   **Peso y frenado**: carga útil cambia la inercia; con 25 t la
    distancia de frenado se duplica.

-   **Altura máxima 4.25 m y ancho 2.60 m (NOM-012)**: definen qué
    accesos y helicoidales puede usar cada vehículo (las helicoidales
    solo para autos y pick-ups).

-   **Carrocería**: redilas (carga a granel, se tapa con lona y se
    amarra con reata), caja seca (tarimas o cajas apiladas), refrigerada
    (consume diésel extra, reduce merma 60 a 80%).

Fuentes: [The Logistics World ---
rabón](https://thelogisticsworld.com/transporte/camion-rabon-capacidad-carga-medidas-principales-usos-ventajas-mexico-sict/),
[The Logistics World ---
torton](https://thelogisticsworld.com/transporte/camion-torton-capacidad-carga-medidsa-principales-usos-ventajas-mexico-sict/),
[adn40 ---
NOM-012](https://www.adn40.mx/mexico/2025-07-07/cuales-son-camiones-no-pueden-ingresar-a-carretera-mexico-por-que).
Los modelos listados son las marcas comunes del parque mexicano;
confirma cada uno con fotos de referencia antes de modelar.

## 5. Física y conducción de los camiones

La conducción debe sentirse pesada y técnica, al nivel de un simulador
tipo Euro Truck pero en espacios estrechos y saturados: el reto no es la
carretera sino meter 23 m de tráiler en reversa entre dos tortons, con
diableros cruzando.

### Modelo físico por vehículo (parámetros a exponer en datos)

  -----------------------------------------------------------------------------------
  Parámetro         Pick-up   3.5 t     Rabón      Torton    Tráiler 53\'    Full
  ----------------- --------- --------- ---------- --------- --------------- --------
  Masa vacío (t)    1.8       3.2       7          9.5       15              20
                                                             (tracto+caja)   

  Carga útil máx.   0.8       3.5       9          16        24              48
  (t)                                                                        

  Potencia (hp)     160       300       230 a 260  300 a 350 450 a 500       500 a
                                                                             600

  Transmisión       Manual 5  Autom. 6  Manual 6 a Manual 9  Manual 10 a 18  Manual
                    / autom.            9          a 10      / autom.        18
                                                   (Eaton                    
                                                   Fuller)                   

  Distancia entre   3.2       4.2       5.0        5.5       5.8 + 13        5.8 + 2
  ejes (m)                                                                   x 10

  Radio de giro     6         7.5       9          10.5      13 a 14         14+
  aprox. (m)                                                                 

  Freno de motor /  No        No        Opcional   Sí (Jake  Sí              Sí
  retardador                                       brake)                    
  -----------------------------------------------------------------------------------

*Valores orientativos de diseño; calibrar con pruebas de juego.*

### Sistemas de conducción

1.  **Articulación real**: quinta rueda (pivote) para tráiler; dolly con
    segunda articulación para el full. La reversa de un full debe ser
    casi imposible sin ayuda (como en la realidad: se desenganchan los
    remolques).

2.  **Transferencia de peso**: el centro de masa sube con carga apilada
    a granel en redilas; frenar o girar fuerte con 3.5 t cargada de
    sandía puede tirar carga (pérdida) o volcar.

3.  **Frenos de aire**: retardo de 0.3 a 0.5 s al pisar; presión de aire
    que se recarga; freno de estacionamiento (\"la perilla amarilla\")
    obligatorio al estacionar en andén.

4.  **Cambios**: modo automático, semi y manual con clutch; en manual,
    el \"doble embrague\" para tortons viejos como reto opcional.

5.  **Puntos ciegos y espejos**: espejos laterales y de cofre
    funcionales; cámara de reversa como mejora comprable; sin cámara, un
    NPC \"viene, viene\" (el ayudante que da indicaciones) guía con
    señas y gritos.

6.  **Superficie**: pavimento con baches, topes, charcos y restos de
    fruta (lechuga y plátano aplastado = menos tracción); en lluvia las
    calles se encharcan.

7.  **Daño**: abolladuras, llantas ponchadas, redilas rotas; daño a
    terceros con multa o \"arreglo\" en el momento.

### Maniobras típicas de la CEDA (misiones de conducción)

-   **Entrada por caseta**: alinear, frenar, pagar cuota según tipo
    (auto \~\$10; unidades grandes hasta \~\$120 según letreros de
    acceso), recibir boleto.

-   **Acomodo en batería al andén**: reversa a 90° hasta pegar la caja a
    la bodega, con espacio de 3 a 3.5 m entre unidades.

-   **Cortes de maniobra**: en calles de servicio con tráfico en doble
    sentido, hacer 3 a 5 cortes para entrar a un hueco.

-   **Salida en hora pico**: cola de cientos de unidades, claxon, NPCs
    que se meten, cuidar no rozar.

-   **Pernocta**: estacionarse en la Zona de Pernocta (hasta 424
    unidades de 30 t) y dormir en la cabina-litera.

-   **Recorrido externo (opcional, fase 2)**: rutas cortas a mercados
    (Jamaica, Merced, tianguis de Iztapalapa) por Eje 6 Sur, Canal de
    Río Churubusco, Canal de Apatlaco y Ermita Iztapalapa, con Hoy No
    Circula y tráfico de la ciudad.

### IA de tráfico

-   **Capas**: vehículos lejanos simulados como flujo (sin física),
    cercanos con física completa.

-   **Comportamientos**: choferes con prisa que se cierran, unidades
    estacionadas en doble fila descargando, camionetas que se paran a
    media calle para subir 3 cajas, tránsito que abanderan los \"viene
    viene\".

-   **Reglas de prioridad**: los diableros tienen paso de facto; un
    camión en reversa bloquea el carril; las patrullas internas multan
    por estacionarse en zonas prohibidas.

-   **Atascos emergentes**: un tráiler mal acomodado bloquea una calle y
    genera embotellamiento que el sistema propaga (oportunidad de
    misión: ayudar a desatorar).

## 6. Productos, unidades de venta y precios

En la CEDA casi nada se vende por kilo suelto: se vende por **caja,
arpilla, costal, reja, manojo, tonelada o camión completo**. El juego
debe mostrar el precio por unidad comercial y por kilo, igual que el
SNIIM, que publica a diario precio mínimo, máximo y frecuente por
producto y origen.

### Precios de mayoreo reales en la CEDA (SNIIM, 12 a 16 oct 2026)

  -----------------------------------------------------------------------------------
  Producto          Origen       \$/kg      Presentación     Precio por  Vida útil
  (calidad)                                 típica           unidad      para el
                                                             aprox.\*    juego
  ----------------- ------------ ---------- ---------------- ----------- ------------
  Jitomate          Puebla       \$25.83    Caja de madera   \~\$335     5 a 7 días
  saladette                                 \~13 kg                      

  Jitomate bola     Puebla       \$45.00    Caja \~10 kg     \~\$450     5 a 7 días

  Aguacate Hass     Michoacán    \$36.67    Caja \~10 kg     \~\$365     4 a 8 días
                                                                         (madura)

  Limón con semilla Michoacán    \$16.50    Caja / arpilla   \~\$315     10 a 14 días
  #5                                        19 kg                        

  Limón con semilla Michoacán    \$12.63    Caja 19 kg       \~\$240     10 a 14 días
  #4                                                                     

  Limón sin semilla Veracruz     \$9.00     Arpilla \~20 kg  \~\$180     10 a 14 días
  (persa)                                                                

  Cebolla bola      Chihuahua    \$42.00    Arpilla/costal   \~\$1,050   20 a 30 días
                                            \~25 kg                      

  Cebolla de rabo   Puebla       \$16.00    Manojo / por kg  ---         3 a 5 días

  Papa alpha        Edomex       \$14.00    Arpilla 50 kg    \~\$700     20 a 30 días

  Naranja Valencia  Veracruz     \$12.30    A granel por     \~\$310 /   10 a 15 días
  mediana                                   tonelada o       costal      
                                            costal \~25 kg               

  Naranja Valencia  Veracruz     \$6.30     A granel /       \~\$160 /   10 a 15 días
  chica (jugo)                              costal           costal      

  Plátano Tabasco   Tabasco      \$6.11     Caja \~18 kg     \~\$110     4 a 6 días

  Plátano macho     Chiapas      \$15.00    Caja / racimo    ---         6 a 10 días

  Plátano dominico  Chiapas      \$14.44    Caja             ---         4 a 6 días

  Chile serrano     San Luis     \$21.00    Arpilla / caja   \~\$210     7 a 10 días
                    Potosí                  \~10 kg                      

  Chile jalapeño    Jalisco      \$21.00    Arpilla \~10 kg  \~\$210     7 a 10 días

  Chile poblano     Baja         \$22.00    Caja \~10 kg     \~\$220     7 a 10 días
                    California                                           

  Pimiento morrón   Sinaloa      \$29.17    Caja \~10 kg     \~\$290     7 a 10 días

  Chile guajillo    Zacatecas    \$125.00   Costal / por kg  ---         Meses
  (seco)                                                                 

  Chile pasilla     Zacatecas    \$180.00   Costal / por kg  ---         Meses
  (seco)                                                                 

  Chile ancho       Zacatecas    \$135.00   Costal / por kg  ---         Meses
  (seco)                                                                 
  -----------------------------------------------------------------------------------

*Precio por unidad = \$/kg x peso de la presentación, redondeado; los
pesos de caja varían por bodega. Fuentes: [AgroPrecios /
SNIIM](https://www.agropreciosmx.com/precio/)
([jitomate](https://www.agropreciosmx.com/precio/jitomate/),
[limón](https://www.agropreciosmx.com/precio/limon/),
[aguacate](https://www.agropreciosmx.com/precio/aguacate/),
[cebolla](https://www.agropreciosmx.com/precio/cebolla/),
[papa](https://www.agropreciosmx.com/precio/papa/),
[naranja](https://www.agropreciosmx.com/precio/naranja/),
[plátano](https://www.agropreciosmx.com/precio/platano/),
[chile](https://www.agropreciosmx.com/precio/chile/)).*

### Rango de referencia por temporada (para el generador de precios)

El precio de un mismo producto se mueve fuerte en el año: el jitomate en
la CEDA estuvo cerca de \$21.60/kg en febrero de 2026, la inflación del
jitomate llegó a 152% en marzo por heladas y granizo, y bajó a unos
\$30/kg en junio
([Gastrolab](https://www.gastrolabweb.com/tips/2026/2/25/cuanto-cuesta-el-kilo-de-jitomate-en-los-primeros-meses-de-2026-63580.html),
[El
Imparcial](https://www.elimparcial.com/dinero/2026/06/08/el-precio-del-jitomate-baja-a-30-pesos-por-kilo-en-la-central-de-abasto-tras-registrar-una-inflacion-historica-de-152-aliviando-de-forma-directa-el-gasto-diario-en-la-canasta-basica-familiar/)).
Por eso cada producto necesita: precio base, curva estacional,
volatilidad y choque por evento.

### Catálogo completo de productos a incluir (MVP 40 SKU)

-   **Hortalizas de fruto**: jitomate saladette y bola, tomate verde,
    chiles frescos (serrano, jalapeño, poblano, de árbol, habanero,
    manzano), pimiento, calabacita, chayote, pepino, berenjena, elote.

-   **Raíces y bulbos**: papa (alpha, blanca, cambray), cebolla (bola,
    morada, de rabo), ajo, zanahoria, betabel, jícama, camote.

-   **Hoja y hierba**: lechuga (romana, orejona, bola), col, brócoli,
    coliflor, espinaca, cilantro, perejil, epazote, verdolaga, quelites;
    nopal (por ciento o \"tambo\").

-   **Cítricos**: limón con y sin semilla, naranja Valencia (jugo,
    mediana, grande), mandarina, toronja.

-   **Tropicales**: plátano (Tabasco, macho, dominico, manzano), papaya
    maradol, piña, mango (Ataulfo, Manila, Tommy), coco, sandía, melón,
    guayaba.

-   **Templados y berries**: manzana (nacional e importada), pera, uva,
    durazno, fresa, zarzamora, frambuesa, arándano, tejocote
    (temporada).

-   **Secos**: chiles secos (guajillo, ancho, pasilla, de árbol,
    chipotle, mulato), jamaica, frijol, cacahuate, nuez, pepita.

### Envases y presentaciones (cada una es un asset 3D y una unidad de inventario)

  -----------------------------------------------------------------------
  Envase            Productos                   Notas
  ----------------- --------------------------- -------------------------
  Caja de madera    Jitomate, tomate, chile,    Reutilizable, se compra
  (\"rejilla\" /    aguacate                    en Envases Vacíos
  caja tomatera)                                

  Caja de cartón    Plátano, mango, berries,    Desechable, impresa con
  encerada          morrón                      marca del empaque

  Reja / caja de    Calabacita, elote,          Retornable, con depósito
  plástico          hortaliza                   

  Arpilla (malla)   Cebolla, papa, limón,       10, 20, 25 o 50 kg
                    chile, naranja              

  Costal de rafia   Chile seco, papa, frijol,   25 a 50 kg
                    naranja                     

  Huacal            Fruta de temporada, guayaba Madera ligera, reparada y
                                                revendida

  Manojo / rollo    Cebolla de rabo, cilantro,  Amarrado con liga o tule
                    rábano                      

  A granel (camión) Naranja, sandía, piña,      Se vende por tonelada o
                    melón, coco                 por pieza

  Tarima (pallet)   Cajas de cartón importadas  Requiere patín o
                                                montacargas
  -----------------------------------------------------------------------

## 7. Economía y comercialización

La CEDA funciona como una bolsa de valores de comida: mueve unos 9,000
millones de dólares al año (\~24.6 millones al día) y concentra cerca
del 30% de la producción agrícola del país, así que sus precios fijan
los del resto de México ([El
CEO](https://elceo.com/negocios/como-esta-organizada-la-central-de-abasto/)).
El jugador gana en el diferencial entre comprar en origen o subasta y
vender en bodega o a domicilio, menos flete, cuotas y merma.

### Cadena de valor (cada eslabón es un rol jugable)

1.  **Productor** (Sinaloa, Michoacán, Puebla...) vende el camión
    completo en Subasta o lo consigna a un bodeguero.

2.  **Coyote / comisionista**: compra en el campo o en subasta y
    revende; cobra comisión de 5 a 10% (valor de diseño).

3.  **Bodeguero mayorista**: vende por caja o tonelada; la mayoría de
    comerciantes vende un solo producto.

4.  **Medio mayorista / recaudero**: compra 10 a 100 cajas para mercados
    públicos y tianguis.

5.  **Minorista**: fondas, restaurantes, tianguistas; compran por caja o
    kilo.

6.  **Intermediarios de servicio**: empresas que surten restaurantes
    desde la CEDA (fruta, verdura, abarrote y carne).

### Modelo de precio diario (propuesta)

P\_{d,h} = P\_{base} \\cdot S(mes) \\cdot
\\left(\\frac{D_d}{O_d}\\right)\^{\\varepsilon} \\cdot E_d \\cdot H(h)
\\cdot Q \\cdot (1 + \\sigma \\, \\mathcal{N}(0,1))

-   P base: precio frecuente SNIIM del producto (tabla de la sección 6).

-   S(mes): curva estacional (ej. jitomate caro en marzo, barato en
    febrero).

-   D/O: demanda de NPCs compradores contra oferta de camiones que
    llegaron esa noche; elasticidad entre 0.3 y 0.8.

-   E: choque por evento (helada x1.5, bloqueo carretero x1.3,
    sobreproducción x0.6).

-   H(h): factor por hora: 1.0 a las 4:00, baja hasta 0.7 a 0.8 para
    perecederos después de las 11:00.

-   Q: calidad (primera 1.0, segunda 0.75, rezaga 0.4).

-   σ: volatilidad diaria por producto (limón y jitomate altas; papa y
    cebolla bajas).

### Costos que debe pagar el jugador

  ------------------------------------------------------------------------------------------------------------------------------------------------------
  Concepto       Valor de diseño     Nota
  -------------- ------------------- -------------------------------------------------------------------------------------------------------------------
  Cuota de       Auto \$10;          Cobro real en casetas según letreros ([El
  acceso         camionetas, rabón,  CEO](https://elceo.com/tu-cartera/cuanto-cobran-por-entrar-a-la-central-de-abasto-de-la-cdmx-esta-es-la-tarifa/))
                 torton y tráiler    
                 más alto, hasta     
                 \~\$120             

  Flete por      \$ por km y por eje Torton 3 ejes paga peaje distinto a tráiler 5 ejes
  diésel y                           
  casetas                            

  Diablero       Por caja o por      Los diableros ganan por caja ([Time
                 viaje               Out](https://www.timeoutmexico.mx/ciudad-de-mexico/compras-estilo/central-de-abastos)); valor de diseño \$5 a \$15
                                     por caja según distancia

  Cargadores de  Por camión o por    Cuadrillas de 3 a 6 personas
  descarga       tonelada            

  Renta de       Estimado de juego:  Las bodegas se \"traspasan\" (cesión de derechos) por millones; valores a calibrar
  bodega         \$40k a \$150k al   
                 mes según pasillo   

  Envases        Caja de madera,     Se compran en Envases Vacíos
                 arpilla, reja con   
                 depósito            

  Basura y       Cuota diaria        La CEDA genera más de 400 t de basura al día
  limpieza                           

  Electricidad y Mensual             Reduce merma
  cámara fría                        

  Sueldos        Diario              Despachadores, cobrador, chofer, ayudante

  \"Cuotas\"     Evento opcional     Tema real (en 2013 se detuvo a extorsionadores que pedían \$2,000 a transportistas y bodegueros, [La
  informales y                       Jornada](https://www.jornada.com.mx/2013/07/12/capital)); manejar con cuidado y como riesgo, no como mecánica
  extorsión                          central
  ------------------------------------------------------------------------------------------------------------------------------------------------------

### Merma (deterioro)

-   Cada lote tiene **frescura 100 a 0**; baja por hora según producto,
    temperatura y si está en sol, sombra o cámara fría.

-   Bajo 70: pasa a \"segunda\"; bajo 40: \"rezaga\" (se remata a
    fonderos, juguerías o a ITACATE, el programa de rescate de
    alimentos); bajo 10: basura con costo.

-   Golpes en transporte (frenazos, baches, sobre-apilado) restan
    frescura: jitomate y fresa son frágiles; papa y coco resisten.

### Venta y regateo

-   **Pregonar**: el jugador grita precio y producto (\"¡lleve lo bueno,
    lleve lo barato!\") para atraer compradores en el pasillo; alcance y
    efecto según carisma.

-   **Regateo** por turnos: el NPC abre con 10 a 20% menos; cada
    contraoferta cuesta paciencia; si el jugador cede, sube su
    reputación con ese cliente.

-   **\"Probadita\" y calidad**: el comprador abre una caja al azar; si
    la de abajo viene mala (\"cama\"), baja la confianza.

-   **Báscula**: pesar y descontar tara del envase; trampas posibles
    (báscula arreglada) con riesgo de multa de Profeco.

-   **Crédito y \"fiado\"**: clientes frecuentes piden pagar la
    siguiente semana; riesgo de impago; libreta de cuentas.

-   **Pedidos**: restaurantes y supermercados piden entregas recurrentes
    con calidad mínima y hora de llegada.

-   **Pago**: efectivo dominante, transferencia y terminal como mejora;
    riesgo de robo si se carga mucho efectivo.

## 8. Personajes y NPCs: roles, rutinas y animaciones

Con hasta medio millón de visitantes y 70,000 a 90,000 trabajadores al
día, el juego no puede simular a todos: se recomienda una IA por capas
con \~300 a 800 agentes completos alrededor del jugador y multitudes
instanciadas más lejos. Cada NPC tiene un **rol, horario, ruta,
inventario y estado de ánimo**.

### Catálogo de NPCs

  --------------------------------------------------------------------------
  NPC             Horario      Rutina y comportamiento  Animaciones y audio
                  activo                                clave
  --------------- ------------ ------------------------ --------------------
  Diablero /      1:00 a 14:00 Espera en esquinas;      Empujar, inclinar
  cartillero                   acepta encargo; carga 10 diablo, frenar con
  (\~11,000                    a 40 cajas; corre por el el pie, amarrar con
  reales)                      pasillo; cobra por caja; reata; grito
                               renta el diablo a una    \"¡golpe avisa!\" /
                               empresa                  \"¡ahí va el
                                                        diablo!\"

  Bodeguero       22:00 a      Recibe camión, revisa    Contar billetes,
  (dueño)         16:00        calidad, fija precio,    revisar fruta,
                               regatea, lleva libreta   señalar, hablar por
                                                        celular

  Despachador /   1:00 a 15:00 Apila cajas, pesa,       Cargar caja al
  empleado de                  despacha pedidos         hombro, apilar,
  bodega                                                pesar en báscula

  Gritón /        3:00 a 12:00 Atrae clientes al frente Ademanes, voz en
  pregonero                    de la bodega             loop con variaciones

  Chofer de       20:00 a      Llega, hace fila,        Bajar de cabina,
  tráiler /       10:00        maniobra, duerme en      estirarse, dormir en
  torton                       cabina, negocia flete    litera, revisar
                                                        llantas

  \"Viene viene\" Toda la      Guía reversas con señas  Señas de mano,
  / maniobrista   noche        y silbidos; cobra        silbido, golpecitos
                               propina                  en la caja

  Cargador de     22:00 a 6:00 Descarga camiones a      Cadena humana
  cuadrilla                    destajo, en grupo        pasando cajas,
                                                        costales al hombro

  Productor en    2:00 a 9:00  Vende a pie de camión,   Subir a la caja,
  Subasta                      baja precio si no vende  mostrar producto,
                                                        regatear

  Comprador de    3:00 a 9:00  Recorre varias bodegas,  Caminar con prisa,
  mercado /                    compara, compra volumen, revisar, cargar
  tianguis                     contrata diablero        bolsa de dinero

  Restaurantero / 4:00 a 10:00 Busca calidad, paga más, Oler y tocar fruta,
  chef                         pide factura             tomar notas

  Ama de casa /   7:00 a 15:00 Compra poco, pide \"por  Bolsa de mandado,
  menudeo                      kilo\", regatea fuerte   carrito de dos
                                                        ruedas

  Tamalera,       2:00 a 10:00 Recorre pasillos         Pedalear, servir,
  atolero,                     vendiendo desayuno       grito \"¡tamales,
  cafetero en                                           atole!\"
  triciclo                                              

  Fondera /       6:00 a 17:00 Cocina para              Cocinar, servir,
  comida corrida               trabajadores; compra     cobrar
                               rezaga barata            

  Policía /       24 h         Rondas, multas por       Patrulla, silbato,
  vigilancia CEDA              estacionarse mal,        radio
                               persigue rateros         

  Barrendero /    16:00 a 2:00 Limpia pasillos, recoge  Escoba, carrito,
  recolector                   merma, lleva al transfer compactador
                               de basura                

  Pepenador /     10:00 a      Recoge producto          Agacharse,
  rescatista de   18:00        desechado aprovechable   seleccionar, cargar
  alimentos                                             bolsa

  Ratero /        Hora pico    Busca jugadores con      Correr entre
  carterista                   mucho efectivo; arrebata multitud
                               y huye                   

  Inspector /     Aleatorio    Revisa básculas y        Portapapeles, multa
  Profeco                      precios                  

  Coyote /        1:00 a 8:00  Ofrece camiones          Celular, apretón de
  comisionista                 completos a precio       manos
                               \"especial\"             

  Vendedor de     22:00 a      Vende y repara cajas y   Martillar, apilar
  envases         10:00        huacales                 envases

  Perros          24 h         Rondan basura y fondas   Olfatear, dormir,
  callejeros                   (hay refugio canino en   ladrar
                               la CEDA)                 
  --------------------------------------------------------------------------

### Sistema de comportamiento (IA)

-   **Agenda diaria (schedule)**: cada rol tiene bloques de horario; a
    la hora X cambia de objetivo (llegar, trabajar, comer, descansar,
    irse).

-   **Árbol de comportamiento / GOAP** con metas: comprar barato, vender
    todo antes de mediodía, ganar propinas, no ser atropellado.

-   **Navegación por capas**: navmesh peatonal (pasillos), carriles de
    diablos (centro del pasillo, más rápido), red vial de camiones; los
    diableros invaden ambos.

-   **Multitud**: densidad que sube de 3:00 a 7:00; flujo bidireccional;
    esquivar y empujarse; cuellos de botella frente a bodegas populares.

-   **Memoria y reputación**: los clientes recuerdan precio, calidad y
    trato; vuelven o te recomiendan.

-   **Reacciones**: claxon, gritos, se apartan del diablo, se acercan a
    un pregonero, se enojan si se les cierra el paso.

-   **Barks contextuales** (frases cortas) en español chilango: \"¿a
    cómo la caja?\", \"échele más\", \"pa\' la otra\", \"¿me lo deja
    en...?\", \"¡abusado!\"; mínimo 300 líneas por rol principal con
    voces variadas.

## 9. Mecánicas de juego, progresión, misiones y eventos

La progresión sigue la escalera social real de la CEDA: de diablero a
dueño de varias bodegas y flotilla de tráileres. Cada escalón desbloquea
un vehículo y una mecánica nueva.

### Escalera de progresión

  ------------------------------------------------------------------------------
  Nivel   Rol           Vehículo     Mecánica que se desbloquea  Meta para subir
  ------- ------------- ------------ --------------------------- ---------------
  1       Diablero      Diablito     Mover carga a pie,          Comprar diablo
                        rentado      propinas, rutas de pasillo  propio

  2       Ayudante /    Diablo de    Descarga de camiones,       Ahorrar para
          cargador      plataforma   cuadrilla                   camioneta

  3       Fletero       Pick-up o    Fletes a mercados y fondas, Clientes fijos
                        estaquitas   primera compra-venta        

  4       Comerciante   Tres y media Comprar en subasta,         Rentar bodega
          de subasta                 revender en tianguis        

  5       Bodeguero     Rabón        Bodega propia, empleados,   2a bodega o
                                     precio, crédito             contrato con
                                                                 supermercado

  6       Mayorista     Torton +     Compra directa a            Flotilla
                        tráiler      productores en otros        
                                     estados, cámara fría        

  7       Empresario    Flotilla y   Contratos, exportación,     Ser \"el rey
                        full         bodegas de transferencia    del limón\" (o
                                                                 del producto
                                                                 elegido)
  ------------------------------------------------------------------------------

### Bucle principal (una jornada)

1.  **Planear** (tarde/noche): revisar precios SNIIM del día, pedidos y
    clima.

2.  **Abastecer** (22:00 a 4:00): manejar a origen o recibir camión; o
    comprar en Subasta.

3.  **Descargar y acomodar** (1:00 a 4:00): contratar cargadores,
    apilar, poner lo bonito al frente.

4.  **Vender** (3:00 a 11:00): pregonar, regatear, despachar, entregar
    con diablero o flete.

5.  **Rematar y cerrar** (11:00 a 16:00): bajar precio de lo que se va a
    echar a perder, cobrar fiados, pagar sueldos.

6.  **Mejorar** (noche): invertir en vehículos, bodega, empleados,
    cámara fría; descansar.

### Tipos de misión

-   **Flete urgente**: llevar 80 cajas de jitomate a un restaurante en
    Polanco antes de las 7:00.

-   **Desatorar**: un tráiler quedó mal acomodado; maniobrarlo o guiarlo
    como \"viene viene\".

-   **Compra de oportunidad**: un productor necesita vender su torton de
    mango antes de irse; precio bajo pero producto maduro.

-   **Pedido de temporada**: 2 t de cempasúchil para Día de Muertos,
    tejocote y caña para posadas.

-   **Ruta de reparto**: 6 entregas por Iztapalapa con tráfico, Hoy No
    Circula y topes.

-   **Licitación**: surtir un supermercado con calidad y cantidad fijas
    cada semana.

-   **Rescate de alimento**: donar rezaga a ITACATE a cambio de
    reputación.

### Eventos dinámicos (afectan oferta, demanda o tráfico)

  ------------------------------------------------------------------------
  Evento                   Efecto                      Frecuencia sugerida
  ------------------------ --------------------------- -------------------
  Helada o granizo en zona Sube jitomate y hoja 30 a   Invierno
  productora               150%                        

  Bloqueo carretero / paro Llegan menos camiones; sube 1 o 2 al mes
  de transportistas        todo                        

  Sobreproducción          Precio se desploma          Temporada de
                                                       cosecha

  Lluvia fuerte            Encharcamientos, menos      Junio a septiembre
                           compradores, más merma      

  Incendio en bodegas      Zona cerrada, pérdidas (ha  Raro
                           ocurrido en Flores y        
                           Hortalizas)                 

  Operativo policial /     Multas a básculas y         Semanal
  revisión Profeco         estacionamiento             

  Robo de mercancía o      Pérdida; seguro como mejora Aleatorio
  efectivo                                             

  Fiestas (Muertos, 12     Picos de demanda            Calendario
  dic, Navidad, Cuaresma,  específicos                 
  Patrias)                                             

  Ponchadura / falla       Retraso, grúa, taller       Según mantenimiento
  mecánica                                             
  ------------------------------------------------------------------------

### Sistemas de soporte

-   **Fatiga del chofer** (horas sin dormir) afecta reflejos y visión;
    café, siesta en pernocta.

-   **Mantenimiento**: aceite, llantas, frenos, verificación.

-   **Empleados** con habilidad, lealtad y sueldo; pueden robar o
    renunciar.

-   **Reputación** por pasillo y por tipo de cliente.

-   **Celular in-game**: WhatsApp de pedidos, precios SNIIM, mapa,
    banco.

-   **Modos**: carrera, sandbox (dinero libre), solo conducción,
    multijugador cooperativo (una bodega entre amigos) como fase
    posterior.

## 10. Lista de assets e imágenes de referencia

Para un vertical slice (una nave de Frutas, un tramo de Subasta y una
caseta) se necesitan unos 250 assets únicos; la CEDA completa escala por
variaciones e instancias. Las fotos de referencia se muestran en el chat
de esta conversación; abajo, qué fotografiar o buscar para cada grupo.

### Modelos 3D

  ------------------------------------------------------------------------
  Grupo          Assets mínimos                        LOD / variantes
  -------------- ------------------------------------- -------------------
  Vehículos      4 tractos (estilo Kenworth,           3 LOD, 6 colores,
                 Freightliner, International, Volvo),  rotulados de
                 cajas 53\' seca y refrigerada,        empresas ficticias,
                 plataforma 48\', dolly y full, torton suciedad y
                 redilas y caja seca, rabón, tres y    abolladuras
                 media, estaquitas, pick-up, panel,    
                 auto, taxi, Cedabús, patrulla         

  Equipo de      Diablito, diablo de plataforma, patín Desgaste
  patio          hidráulico, montacargas, triciclo,    
                 carrito de basura, báscula de         
                 plataforma y de colgar                

  Arquitectura   Módulo de bodega 5 x 20 m (cortina,   Modular, sin marcas
                 tapanco, oficina), techo de nave,     reales
                 andén, rampa helicoidal, caseta de    
                 acceso con plumas, pernocta, subasta  
                 (techumbre abierta), Envases Vacíos,  
                 transfer de basura, fondas, bancos,   
                 capilla, paneles solares              

  Producto       40 SKU x 3 estados (primera, segunda, Instancing, pila
                 rezaga) + versión a granel            procedural

  Envases        Caja de madera, cartón, reja de       Llenos y vacíos,
                 plástico, arpilla, costal, huacal,    rotos
                 tarima, manojo                        

  Utilería       Lonas, reatas, letreros de precio a   Decals de suciedad
                 mano en cartón, focos colgantes,      
                 básculas, cubetas, mangueras, basura  
                 orgánica, charcos, cajas apiladas     

  Personajes     20 roles x 5 variantes de cuerpo,     Animación
                 ropa de trabajo (faja, gorra, mandil, compartida por
                 botas, sudadera)                      esqueleto
  ------------------------------------------------------------------------

### Animación (motion capture recomendado)

Empujar y jalar diablo (vacío y cargado), cargar caja al hombro, pasar
caja en cadena, apilar, pesar, contar dinero, regatear (gestos),
pregonar, dormir en cabina, subir y bajar de camión, señas de \"viene
viene\", barrer, cocinar en comal, pedalear triciclo, huir.

### Audio

-   **Ambientes por hora**: madrugada (motores diésel, frenos de aire,
    reversa con alarma), pico (multitud, gritos, radios con cumbia y
    banda), tarde (cortinas cerrándose, escobas).

-   **Vehículos**: motor por clase, freno de motor (Jake), cambios,
    claxon de aire, freno de aire liberando presión.

-   **Voces**: pregones, \"¡golpe avisa!\", regateo, barks; actores con
    acento chilango y de provincia.

-   **Música**: original, estilo cumbia, sonidero y norteño; evitar
    licenciar canciones existentes sin derechos.

### UI

Tablero de precios estilo SNIIM (mín/máx/frecuente), libreta de cuentas,
celular, mapa por pasillo y número, indicador de frescura por lote, peso
y balance del camión, cámara de reversa y guías de maniobra, reloj con
fase del día.

### Referencias visuales a reunir (fotos propias o con licencia)

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Tema               Qué capturar               Dónde buscar
  ------------------ -------------------------- -------------------------------------------------------------------------------------------------------------------------------
  Mapa general       Plano por sectores y       Mapa oficial CEDA reproducido en
                     pasillos                   [Chilango](https://www.chilango.com/que-hacer/guia-para-comprar-en-la-central-de-abasto-horarios-pasillos-y-todo-lo-que-hay/) y
                                                [El CEO](https://elceo.com/negocios/cuantas-tiendas-y-bodegas-hay-en-la-central-de-abastos/)

  Vista aérea        Patrón de naves, techos    Imágenes satelitales (Google Earth) para el blockout a escala
                     solares, calles            

  Pasillo de frutas  Fachadas, letreros,        Visita en hora pico (3:00 a 7:00)
                     iluminación, pilas de      
                     cajas                      

  Andenes y camiones Acomodo en batería,        Visita nocturna; videos de choferes \"descargar en la Central\"
                     distancias, redilas, lonas 

  Subasta            Venta a pie de camión,     Reportaje de
                     manojeo, lechugueros       [N+](https://www.nmas.com.mx/ciudad-de-mexico/central-de-abasto-de-la-cdmx-subastas-un-espacio-de-venta-a-mayoreo-y-menudeo/)

  Diableros          Tipos de diablo, amarres,  Visitas guiadas gratuitas de la CEDA
                     carga máxima, uniformes    ([Chilango](https://www.chilango.com/que-hacer/central-de-abasto-lanza-visitas-guiadas-gratis-cultura-gastronomia/))

  Vehículos          Torton, rabón, 3.5 t con   Catálogos de fletes y fabricantes; fotos en sitio
                     redilas de madera,         
                     tráileres 53\'             

  Envases            Cajas de madera, huacales, Sector Envases Vacíos
                     rejas                      
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Antes de usar cualquier foto de internet como textura o en marketing,
consigue licencia o toma fotos propias; las marcas reales de camiones y
bodegas deben reemplazarse por diseños ficticios salvo acuerdo de
licencia.

## 11. Arquitectura técnica y plan de producción

Recomendación: Unreal Engine 5 (Chaos Vehicles, Mass AI para multitudes,
World Partition para 327 ha) o Unity 6 con DOTS si el equipo domina C#.
Lo más difícil técnicamente son tres cosas: la física de vehículos
articulados, miles de NPCs a la vez y la simulación económica
persistente.

### Módulos del sistema

  -----------------------------------------------------------------------
  Módulo               Responsabilidad          Tecnología sugerida
  -------------------- ------------------------ -------------------------
  Reloj y calendario   Hora, día, temporada,    Singleton con escala de
                       eventos                  tiempo variable

  Simulación económica Precios, oferta,         Tablas de datos +
                       demanda, inventario de   simulación por ticks
                       cada bodega              (cada 10 min de juego)

  Inventario y lotes   Producto, calidad,       ECS / data-oriented
                       frescura, envase, peso,  
                       dueño                    

  Vehículos            Física, articulación,    Chaos Vehicles o solución
                       carga, daño, combustible propia con constraints

  Tráfico              Red vial interna,        Grafo de carriles + flujo
                       casetas, andenes,        macro lejos del jugador
                       prioridades              

  NPC / multitudes     Agenda, metas,           Mass AI / DOTS + behavior
                       navegación, reacciones   trees para cercanos

  Diálogo y regateo    Barks, negociación por   Sistema de diálogo por
                       turnos, reputación       datos (YAML/JSON)

  Guardado             Estado de mercado,       Serialización por
                       bodegas, flotilla,       capítulos/días
                       relaciones               

  Datos reales         Importar precios SNIIM   Script que lee el CSV del
  (opcional)           como base                SNIIM y genera P base y
                                                curvas
  -----------------------------------------------------------------------

### Presupuesto de rendimiento (objetivo PC media, 60 fps)

-   Agentes completos cercanos: 300 a 800; multitud instanciada: 5,000+
    visibles.

-   Vehículos con física completa: 30 a 60; resto como flujo animado.

-   Producto: pilas de cajas con instancing (miles de cajas por
    pasillo).

-   Streaming por nave: cargar a detalle solo la nave y calles donde
    está el jugador.

### Plan de producción por fases

1.  **Preproducción (2 a 3 meses)**: visita de campo con fotos, video y
    grabación de audio (madrugada y pico); blockout de 1 nave a escala;
    prototipo de conducción de torton y tráiler en reversa; hoja de
    cálculo de economía.

2.  **Vertical slice (4 a 6 meses)**: 1 nave de Frutas, 1 tramo de
    Subasta, 1 caseta, 3 vehículos (diablo, 3.5 t, torton), 10 SKU, 8
    roles NPC, un día completo jugable.

3.  **Producción alfa (8 a 12 meses)**: Frutas y Legumbres completo,
    Subasta, Pernocta, Envases, 40 SKU, 12 vehículos, progresión hasta
    bodeguero, eventos.

4.  **Beta (4 a 6 meses)**: resto de sectores, temporadas y fiestas,
    balance económico, optimización, localización.

5.  **Lanzamiento y después**: rutas externas por la ciudad,
    multijugador cooperativo, mods de vehículos.

### Equipo mínimo sugerido

Director/diseñador de juego, 2 programadores de gameplay (vehículos y
economía), 1 programador de IA, 2 artistas 3D (entorno y vehículos), 1
artista de personajes, 1 animador, 1 diseñador de audio, 1 QA. Las
cifras de tiempo y equipo son estimaciones de planeación, no datos de
investigación.

### Preguntas abiertas para decidir antes de producir

-   ¿Primera persona, tercera persona o ambas (a pie y en cabina)?

-   ¿Tono simulador realista o arcade/humor?

-   ¿Se usan nombres y logos reales (CEDA, marcas de camiones) con
    licencia o versiones ficticias?

-   ¿Incluir extorsión y robo como sistemas, o solo como eventos
    ligeros?

-   ¿Plataforma objetivo: PC, consola, móvil?

## 12. Fuentes

-   [Gobierno CDMX --- Central de
    Abasto](https://mexicocity.cdmx.gob.mx/venues/central-de-abasto/)

-   [La Jornada --- cifras del Fideicomiso
    (2005)](https://www.jornada.com.mx/2005/05/16/003n1sec.html)

-   [El CEO --- bodegas, sectores y
    naves](https://elceo.com/negocios/cuantas-tiendas-y-bodegas-hay-en-la-central-de-abastos/)

-   [El CEO --- cuota de
    acceso](https://elceo.com/tu-cartera/cuanto-cobran-por-entrar-a-la-central-de-abasto-de-la-cdmx-esta-es-la-tarifa/)

-   [El CEO --- organización y valor de
    operación](https://elceo.com/negocios/como-esta-organizada-la-central-de-abasto/)

-   [Chilango --- guía de pasillos y
    mapa](https://www.chilango.com/que-hacer/guia-para-comprar-en-la-central-de-abasto-horarios-pasillos-y-todo-lo-que-hay/)

-   [Chilango --- visitas guiadas y salidas
    diarias](https://www.chilango.com/que-hacer/central-de-abasto-lanza-visitas-guiadas-gratis-cultura-gastronomia/)

-   [Chilango --- canasta básica y largo de
    pasillos](https://www.chilango.com/noticias/bara-bara-bara-bara-central-de-abasto-tiene-la-canasta-basica-mas-barata-de-cdmx-esto-cuesta/)

-   [Chilango --- 40 años y
    horarios](https://www.chilango.com/agenda/otros/todos-los-caminos-llevan-a-la-central-de-abasto/)

-   [Food & City --- subasta y
    diableros](https://foodandcity.org/city-feeds-mexico/)

-   [N+ --- zona de
    Subasta](https://www.nmas.com.mx/ciudad-de-mexico/central-de-abasto-de-la-cdmx-subastas-un-espacio-de-venta-a-mayoreo-y-menudeo/)

-   [Time Out --- diableros y
    bodegas](https://www.timeoutmexico.mx/ciudad-de-mexico/compras-estilo/central-de-abastos)

-   [La Jornada --- Cedabús
    (2014)](https://www.jornada.com.mx/2014/07/23/capital/032n1cap)

-   [La Jornada --- extorsión
    (2013)](https://www.jornada.com.mx/2013/07/12/capital)

-   [AgroPrecios / SNIIM --- precios de mayoreo oct
    2026](https://www.agropreciosmx.com/precio/)

-   [El Imparcial --- jitomate jun
    2026](https://www.elimparcial.com/dinero/2026/06/08/el-precio-del-jitomate-baja-a-30-pesos-por-kilo-en-la-central-de-abasto-tras-registrar-una-inflacion-historica-de-152-aliviando-de-forma-directa-el-gasto-diario-en-la-canasta-basica-familiar/)

-   [Gastrolab --- jitomate feb
    2026](https://www.gastrolabweb.com/tips/2026/2/25/cuanto-cuesta-el-kilo-de-jitomate-en-los-primeros-meses-de-2026-63580.html)

-   [The Logistics World --- camión
    rabón](https://thelogisticsworld.com/transporte/camion-rabon-capacidad-carga-medidas-principales-usos-ventajas-mexico-sict/)

-   [The Logistics World --- camión
    torton](https://thelogisticsworld.com/transporte/camion-torton-capacidad-carga-medidsa-principales-usos-ventajas-mexico-sict/)

-   [adn40 --- NOM-012 y
    full](https://www.adn40.mx/mexico/2025-07-07/cuales-son-camiones-no-pueden-ingresar-a-carretera-mexico-por-que)
