const http = require('http');

const port = process.env.PORT || 8080;

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ service: '${{ values.name }}', status: 'ok' }));
});

server.listen(port, () => {
  console.log(`${{ values.name }} listening on port ${port}`);
});
