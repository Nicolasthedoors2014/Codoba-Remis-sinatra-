Paradigmas de la Programación 2017 - Lab 2

# Cordoba remis

  Aplicación web para conectar pasajeros con conductores particulares.

## Funcionamiento

  Un usuario se puede registrar como pasajero o como conductor, para tomar viajes o para ofrecer traslado respectivamente.
  Para registrarse como pasajero es necesario un nombre de usuario, un email y un telefono(opcional).
  Como conductor se solicita la patente del vehículo con el que se ofrezca dicho servicio de transporte y definir una tarifa por kilómetro.
  Al solicitar un viaje se listan los conductores lo suficientemente cerca para realizarlo, cuanto cobran por el, además la posibilidad de acceder a su perfil para ver mas información, y se puede elegir el que mas guste.
  Al finalizar, se puede pagar desde la aplicación y también dar una opinión del conductor, calificandolo con estrellas de 1 a 5 estrellas.
  Por cada viaje que se realiza se pueden acumular las millas de este, dando la posibilidad de canjear estas por los descuentos que estén disponibles en dicho momento.
  Los conductores pueden consultar el dinero que han ganado hasta el momento, demás información referente a el como las puntuaciones que ha recibido de los usuarios.


## Implementación

Se modificaron los siguientes archivos dados por la cátedra : app.rb y controller.rb , archivos ruby ubicados en bin;
available_trips.erb, finish_trip.erb, list_trip.erb y profile.erb archivos Embedded RuBy  en views. Además se agregaron archivos, en bin user.rb, passenger.rb y driver.rb, archivos que contienen las clase para definir dichos objetos; en views se agrego un archivo allDrivers.erb para mostrar el listado de todos los conductores.

- app.rb : Archivo principal del la app, aquí se encuentran todas las rutas de esta, funciones que responden a peticiones http, ya sea con metodos GET o POST. Aquí se completaron la implementación de funciones entregadas por la cátedra como '/login', '/pay_trip', etc. Interactúa con la interfaz de la clase AppController para manipular usuarios y localidades.

- controller : Este es otro archivo muy importante, contiene a la clase (AppController) encargada de ofrecer una interfaz a la clase anterior para tratar con los usuarios y localidades. Contiene hashes a objetos usuarios, ya sean pasajeros y conductores, para hacer una busqueda eficiente de estos para obtener información relacionada, una hash para las localidades. También se completaron funciones dadas por la cátedra como load_locations, load_users, etc; y se agregaron otras nuevas como por update_user_info para actualizar por ejemplo el dinero del pasajero o conductor despues de un viaje.

- user.rb : Aquí esta la clase que representa un usuario en general, es decir representa la información que comparten ambos tipos de usuarios, ya sean pasajeros o conductores. De esta clase luego heredan las subclases passanger y driver.
Se opto por esta decisión de diseño en vez de implementar solo una clase passanger y una driver no solo por que nos parecía mas prolijo si no también por que da la posibilidad de agregar a otro tipo de usuario heredando de esta clase también en caso de que en algún momento se lo necesite.

- passanger : subclase de user, se le agrega un atributo miles, el cual es un contador de las millas que recorrió el usuario usando la aplicación.

- driver : subclase de user, este además de los que hereda cuenta con la tarifa por kilometro (fare), un conjunto de opiniones o puntuaciones que los pasajeros que a trasladado le han dado cuantificando la calidad de su servicio, licence el cual representa la patente del auto del conductor.

- location.rb : clase que representa las localidades, cuanta con dos coordenadas x e y , y un nombre, y los metodos get para consultarlos.
