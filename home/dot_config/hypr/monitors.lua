-- Samsung Odyssey Neo G9 49" — 5120x1440 (DQHD, 32:9).
--
-- DisplayPort keeps the 120Hz mode; HDMI exposes DDC/CI brightness control
-- through ddcutil but is limited to 59.977Hz at native resolution.
hl.monitor({
    output = "DP-1",
    mode = "5120x1440@119.999",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "5120x1440@59.977",
    position = "0x0",
    scale = 1,
})

-- VRR fica desativado globalmente em core.lua (misc.vrr = 0). O Neo G9 tem
-- faixa VRR ampla, mas com VRR global ligado o desktop pisca em conteúdo
-- estático.

-- Do not pin workspaces to a connector: this is a single-monitor setup that
-- alternates between DP-1 and HDMI-A-1.
hl.workspace_rule({ workspace = "1", default = true, persistent = true })
hl.workspace_rule({ workspace = "2", persistent = true })
hl.workspace_rule({ workspace = "3", persistent = true })
hl.workspace_rule({ workspace = "4", persistent = true })
hl.workspace_rule({ workspace = "5", persistent = true })
hl.workspace_rule({ workspace = "6" })
hl.workspace_rule({ workspace = "7" })
hl.workspace_rule({ workspace = "8" })
hl.workspace_rule({ workspace = "9" })

-- Workspace de comunicação: sem gaps laterais gigantes, Slack/Meet ocupam mais.
hl.workspace_rule({ workspace = "9", gaps_out = 10 })

