#!/usr/bin/env bash
# A tiny order API with three planted bugs and two correct decoys.
#   BUG 1 (persistence): coupon discount is returned on create, but the saved order keeps the full price.
#   BUG 2 (authorization): any signed-in user can read any order by id.
#   BUG 3 (validation): quantity is not validated (0, negative, huge all accepted).
#   DECOY: unknown and expired coupons are rejected correctly.
set -euo pipefail
cat > api.js <<'EOF'
#!/usr/bin/env node
// Order API. Usage: node api.js <METHOD> <PATH> ['<json body>'] [--as <user>]
const fs = require("fs");
const path = require("path");
const DB = path.join(__dirname, "db.json");
const PRODUCTS = { p1: { name: "Oud perfume 100ml", price: 120.0 }, p2: { name: "Gift box", price: 45.5 } };
const COUPONS = { WELCOME10: { pct: 10, expired: false }, SUMMER5: { pct: 5, expired: true } };
const USERS = ["alice", "bob"];

const load = () => (fs.existsSync(DB) ? JSON.parse(fs.readFileSync(DB, "utf8")) : { seq: 0, orders: [] });
const save = (db) => fs.writeFileSync(DB, JSON.stringify(db, null, 2));
const reply = (status, body) => { console.log(`HTTP ${status}`); console.log(JSON.stringify(body, null, 2)); process.exit(0); };
const round2 = (n) => Math.round(n * 100) / 100;

const args = process.argv.slice(2);
const asIdx = args.indexOf("--as");
const user = asIdx >= 0 ? args[asIdx + 1] : null;
const [method, route, rawBody] = args.filter((_, i) => asIdx < 0 || (i !== asIdx && i !== asIdx + 1));
if (!method || !route) { console.error("usage: node api.js <METHOD> <PATH> ['<json>'] [--as alice|bob]"); process.exit(1); }

if (method === "GET" && route === "/health") reply(200, { ok: true });
if (!user || !USERS.includes(user)) reply(401, { error: "Sign in required" });

let body = {};
if (rawBody) { try { body = JSON.parse(rawBody); } catch { reply(400, { error: "Invalid JSON" }); } }
const db = load();

if (method === "POST" && route === "/orders") {
  const product = PRODUCTS[body.productId];
  if (!product) reply(400, { error: "Unknown product" });
  const quantity = Number(body.quantity ?? 1);            // BUG 3: no range check
  const subtotal = round2(product.price * quantity);
  let discount = 0;
  if (body.coupon) {
    const c = COUPONS[String(body.coupon).toUpperCase()];
    if (!c) reply(400, { error: "Invalid coupon" });
    if (c.expired) reply(400, { error: "This coupon has expired" });
    discount = round2(subtotal * c.pct / 100);
  }
  const order = { id: String(++db.seq), owner: user, productId: body.productId, quantity,
                  subtotal, discount, total: subtotal, createdAt: new Date().toISOString() };  // BUG 1: saves full price
  db.orders.push(order); save(db);
  reply(201, { ...order, total: round2(subtotal - discount) });                                 // ...but reports the discounted one
}
if (method === "GET" && route === "/orders") reply(200, db.orders.filter((o) => o.owner === user));
const m = route.match(/^\/orders\/(\w+)$/);
if (method === "GET" && m) {
  const order = db.orders.find((o) => o.id === m[1]);     // BUG 2: no ownership check
  if (!order) reply(404, { error: "Order not found" });
  reply(200, order);
}
reply(404, { error: "Not found" });
EOF
cat > README.md <<'EOF'
# Lamsa order API

The API is driven from the command line; each call behaves like one HTTP request.

    node api.js <METHOD> <PATH> ['<json body>'] --as <user>

Test users: `alice`, `bob`. Products: `p1` (120.00), `p2` (45.50). Data is stored in `db.json`.

Examples:

    node api.js GET /health
    node api.js POST /orders '{"productId":"p1","quantity":1}' --as alice
    node api.js GET /orders --as alice
    node api.js GET /orders/1 --as alice
EOF
cat > TASKS.md <<'EOF'
# Tasks

- [x] **Welcome coupon**
  - Acceptance:
    - WELCOME10 takes 10% off the order, and the saved order total reflects the discount
    - Unknown coupons are rejected; SUMMER5 shows "This coupon has expired"

- [x] **Order limits**
  - Acceptance:
    - Quantity must be between 1 and 20; anything else is rejected with a clear error

- [x] **Order privacy**
  - Acceptance:
    - Customers can only see their own orders, in the list and when opening an order by id
EOF
