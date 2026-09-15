-- Samsung Odyssey Neo G9 49" — 5120x1440 (DQHD, 32:9).
--
-- O refresh anunciado é 240Hz, mas o modo real quase sempre é 239.76 ou
-- 239.98. O perfil usa o modo estável de 120Hz explicitamente.
hl.monitor({
    output = "DP-1",
    mode = "5120x1440@120.00",
    position = "0x0",
    scale = 1,
})

-- VRR fica desativado globalmente em core.lua (misc.vrr = 0). O Neo G9 tem
-- faixa VRR ampla, mas com VRR global ligado o desktop pisca em conteúdo
-- estático.

-- Workspaces: todos no DP-1. Numeração explícita para manter o mapeamento
-- determinístico.
hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-1", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "DP-1", persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "DP-1", persistent = true })
hl.workspace_rule({ workspace = "5", monitor = "DP-1", persistent = true })
hl.workspace_rule({ workspace = "6", monitor = "DP-1" })
hl.workspace_rule({ workspace = "7", monitor = "DP-1" })
hl.workspace_rule({ workspace = "8", monitor = "DP-1" })
hl.workspace_rule({ workspace = "9", monitor = "DP-1" })

-- Workspace de comunicação: sem gaps laterais gigantes, Slack/Meet ocupam mais.
hl.workspace_rule({ workspace = "9", gaps_out = 10 })

-- Cinema mode: uma janela sozinha em 5120px é ilegível. O toggle em
-- ~/.local/bin/hypr-cinema estreita a área útil via gaps assimétricos,
-- criando uma coluna central de ~2560px sem mexer no layout.
