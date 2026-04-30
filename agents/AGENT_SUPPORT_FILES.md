# Agent Support Files

Solo `agents/ceo/` incluye `HEARTBEAT.md`, `SOUL.md` y `TOOLS.md` porque el CEO tiene responsabilidades de coordinacion, monitoreo y gobierno de la organizacion.

Los demas agentes usan `AGENTS.md` como fuente principal de instrucciones. Esta decision es intencional para reducir superficie de import y evitar que archivos auxiliares contradictorios modifiquen flujos ya probados.

## Regla

Si se agregan `HEARTBEAT.md`, `SOUL.md` o `TOOLS.md` a otro agente, deben cumplir:

- No contradecir el `AGENTS.md` del agente.
- No activar heartbeats si `.paperclip.yaml` los mantiene pausados.
- No introducir nuevos secretos hardcodeados.
- No cambiar el ownership del flujo cold/demo sin actualizar README, IMPORT_READINESS y n8n docs.
