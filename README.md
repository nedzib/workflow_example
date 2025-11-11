# README

## Configuración

1. Instala las dependencias:

   ```bash
   bundle install
   ```

2. Ejecuta las migraciones y carga los datos de ejemplo:

   ```bash
   bin/rails db:setup
   ```

   El seed crea el flujo de trabajo de onboarding y un usuario administrador (`admin@example.com` / `password123`).

3. Inicia la aplicación:

   ```bash
   bin/dev
   ```

## Descripción del workflow

El proyecto incluye una implementación simplificada del motor `rails_workflow` que permite definir plantillas de procesos y operaciones.

Al crear un usuario nuevo (por registro con Devise o desde la consola) se inicia automáticamente el proceso **“Onboarding de nuevo usuario”**, compuesto por cuatro etapas encadenadas:

1. **Recopilar información de perfil** – añade instrucciones de bienvenida.
2. **Verificar correo electrónico** – genera un código de verificación.
3. **Emitir credenciales y accesos** – lista sistemas para provisionar.
4. **Agendar sesión de inducción** – propone una fecha y marca el cierre.

Cada operación ejecuta código Ruby cuando pasa al estado activo para enriquecer su contexto y registrar trazas en el log. Cuando todas las etapas terminan, el proceso invoca un callback que deja constancia de la finalización.

Puedes acceder a la lista de usuarios autenticándote con el usuario administrador y revisar/avanzar cada operación desde la UI.
