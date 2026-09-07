.pragma library

// Matcher de subsequência com scoring estilo fzf, sem dependências.
// Retorna null se `query` não for subsequência de `text`.
//
// Score: bônus por match consecutivo, por início de palavra e por início da
// string; penalidade por caractere pulado. Não é o algoritmo do fzf (que faz
// programação dinâmica para achar o MELHOR alinhamento) — este é guloso,
// pega o primeiro alinhamento válido. Para listas curtas a diferença é
// imperceptível; para milhares de itens, use fuzzysort.

function isBoundary(ch) {
    return ch === " " || ch === "+" || ch === "_" || ch === "-" || ch === ",";
}

function match(query, text) {
    if (!query) return { score: 0, positions: [] };

    var q = query.toLowerCase();
    var t = text.toLowerCase();
    var best = null;

    // Guloso a partir de um ponto só casa o "e" de SUPER antes do "exec".
    // Rodar a partir de cada ocorrência de q[0] e ficar com o melhor custa
    // O(n*m) — irrelevante para listas de centenas de itens.
    for (var s = 0; s < t.length; s++) {
        if (t[s] !== q[0]) continue;
        var m = greedy(q, t, s);
        if (m !== null && (best === null || m.score > best.score)) best = m;
    }
    if (best !== null) best.score -= Math.floor(t.length / 20);
    return best;
}

function greedy(q, t, start) {
    var positions = [];
    var score = 0;
    var qi = 0;
    var prevMatch = -2;

    for (var ti = start; ti < t.length && qi < q.length; ti++) {
        if (t[ti] !== q[qi]) continue;

        if (ti === prevMatch + 1) score += 8;        // consecutivo
        else if (ti === 0) score += 10;              // início da string
        else if (isBoundary(t[ti - 1])) score += 7;  // início de palavra
        else score += 1;

        if (prevMatch >= 0) score -= Math.min(ti - prevMatch - 1, 6);

        positions.push(ti);
        prevMatch = ti;
        qi++;
    }

    if (qi < q.length) return null;
    return { score: score, positions: positions };
}

// items: array de objetos. key: função que extrai a string a casar.
// Retorna novo array ordenado por score decrescente, com `_score` e
// `_positions` anexados.
function filter(items, query, key) {
    var out = [];
    for (var i = 0; i < items.length; i++) {
        var m = match(query, key(items[i]));
        if (m === null) continue;
        var copy = {};
        for (var k in items[i]) copy[k] = items[i][k];
        copy._score = m.score;
        copy._positions = m.positions;
        out.push(copy);
    }
    out.sort(function (a, b) { return b._score - a._score; });
    return out;
}

function escapeHtml(s) {
    return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

// Envolve os caracteres casados em <b> para usar com Text.RichText.
function highlight(text, positions) {
    if (!positions || positions.length === 0) return escapeHtml(text);
    var out = "";
    var set = {};
    for (var i = 0; i < positions.length; i++) set[positions[i]] = true;
    for (var c = 0; c < text.length; c++) {
        var ch = escapeHtml(text[c]);
        out += set[c] ? "<b>" + ch + "</b>" : ch;
    }
    return out;
}

// Realce por coluna: o `_positions` guardado no filtro é relativo ao
// haystack inteiro, então aplicá-lo a uma coluna isolada erra o alvo.
// Recalcula o match contra o texto que vai realmente ser exibido.
function highlightQuery(query, text) {
    if (!query) return escapeHtml(text);
    var m = match(query, text);
    return m === null ? escapeHtml(text) : highlight(text, m.positions);
}
