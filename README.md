# Examen Final – Gestión Comercial

Esta es mi aplicación relacionada con el examen final de Computación Móvil. Es una aplicación para gestionar productos, categorías y proveedores de un negocio.

## ¿Qué hace la APP?

- Permite iniciar sesión con correo y contraseña usando Firebase
- Permite al usuario recuperar la contraseña si ésta ha sido olvidada
- Puedes ver, agregar, editar y borrar productos
- Ver detalle completo de cada producto al tocar su nombre, con opción "Agregar al Carrito"
- Puedes ver, agregar, editar y borrar categorías
- Ver detalle completo de cada categoría al tocar su nombre, con estadísticas simuladas
- Desde el detalle de categoría, puedes ver los productos relacionados al tocar en "Productos"
- Puedes ver, agregar, editar y borrar proveedores
- Ver detalle completo de cada proveedor al tocar su nombre, con email copiable y botón compartir
- Los datos se guardan en la API otorgada exclusivamente para el examen


## ¿Qué necesito para ejecutarla?

- Tener Flutter instalado en la computadora

## ¿Cómo la ejecuto?

1. Abrir la terminal en la carpeta del proyecto
2. Ejecutar `flutter pub get` para instalar las dependencias
3. Ejecutar `flutter run` para correr la aplicación
4. Para cerrarla, presionar la tecla `q` en la terminal

## Datos de la API

Credenciales de la API:

- Dirección: `http://143.198.118.203:8100`
- Usuario: `test`
- Contraseña: `xxxxxxx`

## Organización del código

- `lib/main.dart` - Punto de entrada de la aplicación
- `lib/login_screen.dart` - Pantalla de inicio de sesión
- `lib/screens/` - Pantallas principales (productos, categorías, proveedores)
- `lib/services/` - Conexión con la API
- `lib/providers/` - Manejo de estado de la aplicación


**Autor:** Ricardo Monzón Toro.
