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

La aplicación usa la gema `rails_workflow` y monta un ejemplo de onboarding con cuatro operaciones encadenadas. Las plantillas se siembran en `db/seeds.rb` y se pueden administrar también desde la interfaz `/workflow` que expone la gema.

Cuando se crea un usuario se dispara automáticamente el proceso **“Onboarding de nuevo usuario”** con el contexto necesario (`user_id`, `user_email`, rutas de regreso, etc.). El flujo consta de las etapas:

1. **Recopilar información de perfil** – genera instrucciones y la lista de campos a solicitar.
2. **Verificar correo electrónico** – emite un código temporal para validar al usuario.
3. **Emitir credenciales y accesos** – lista los sistemas internos que deben provisionarse.
4. **Agendar sesión de inducción** – propone una fecha y deja el recordatorio de seguimiento.

Cada transición de estado ejecuta código Ruby a través de `OnboardingWorkflow::StageLogic`, que se enlaza al motor mediante callbacks (`after_create_commit`, `after_update_commit`). Así se enriquecen los datos de contexto de cada operación cuando se activa y se registran marcas de tiempo al completarlas. Al finalizar todas las operaciones, el callback de proceso registra en los logs que el onboarding concluyó para el usuario correspondiente.

Desde la UI autenticada (Devise) puedes revisar la lista de usuarios, abrir cada operación y completarla/skipping/cancelarla según corresponda.
