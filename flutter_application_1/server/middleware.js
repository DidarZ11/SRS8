// Вспомогательный middleware для демонстрации ошибок.
//   GET /__chaos/on?status=500  — все следующие запросы отвечают этим статусом
//   GET /__chaos/off            — вернуть нормальную работу
//   GET /posts?_fail=503        — ошибка только для одного запроса
//   GET /__broken-json          — ответ с некорректным JSON
let chaosStatus = null;

module.exports = (req, res, next) => {
  if (req.path === '/__chaos/on') {
    chaosStatus = Number(req.query.status || 500);
    return res.json({ chaos: chaosStatus });
  }
  if (req.path === '/__chaos/off') {
    chaosStatus = null;
    return res.json({ chaos: null });
  }
  if (req.path === '/__broken-json') {
    res.type('application/json');
    return res.send('{"id": 1, "title": ');
  }
  if (req.query._fail) {
    return res.status(Number(req.query._fail)).json({ error: 'Simulated error' });
  }
  if (chaosStatus) {
    return res.status(chaosStatus).json({ error: 'Chaos mode' });
  }
  next();
};
