# NOTA: 4.9

## Observaciones:

- Un problema fuerte que tuvieron es que, si bien hicieron objetos para todo,
  los objetos no son mucho más complejos que simples hashes, puesto que los
  únicos métodos que utilizan son de acceso a los atributos. La idea del
  laboratorio es que utilicen objetos de verdad (con métodos, atributos de
  instancia, atributos de clase, etc), y no lo hicieron, simplemente
  enmascararon en "objetos" algo que podría haber sido hecho con simples
  hashes.

## Entrega: 80%

- Entregaron users.json
- El tag debió haber sido distinto

## Funcionalidad: 60%

- Cuando me registro no inicia sesión automáticamente
- El costo no se está calculando bien (cuando pido de Plaza San Martin a Cerro
  de las Rosas me da costo cero para cualquier driver)
- En el profile están mostrando todas las reviews de los drivers, en lugar de
  la cantidad de veces que se le dió dicha review.
- También muestran todas las reviews cuando se solicita un viaje en lugar de
  solo mostrar la media de reviews.

## Modularización: 50%

- Los getters no son necesarios, ruby posee `attr_reader` que sirve para eso
  (igualmente `attr_writer` o `attr_accessor` para el caso de `@balance`).
- Falta la implementación de `from_hash`
- Un grueso de la implementación está en el AppController, cuando debería estar
  en los modelos (e.g. calculate distance, podría ser tranquilamente un método
  de la clase Location, o el costo del viaje podría haber sido un método de un
  posible objeto Trip).
- El atributo `@id` de user (autonumerado), se encuentra dos veces. Una vez
  como atributo de clases (que es como debería ser), pero también hay registro
  afuera, que no tiene mucho sentido que esté (`@user_id_count`).
- Están pasando tuplas a los erb, en lugar de utilizar el potencial de Ruby
  para pasar un objeto completo.


## Calidad del código: 25%

- El grueso del código está en un solo archivo (controller.rb)
- Hacen mucho uso de for, cuando el estándar Ruby hace uso exclusivo de each.
- No hacía falta hacer tanta modularización de los objetos, sobre todo teniendo
  en cuenta que no tienen tanto código en si mismos (la modularización es útil
  para no tener archivos únicos de mucho código).
- Hay muchos `return` que no son del estilo de código Ruby
- Líneas de más de 80 caracteres
