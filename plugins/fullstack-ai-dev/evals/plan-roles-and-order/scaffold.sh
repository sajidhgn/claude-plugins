#!/usr/bin/env bash
set -euo pipefail
mkdir -p web/app mobile/app api/app/prompts .github/workflows
cat > web/package.json <<'EOF'
{"name":"web","scripts":{"dev":"next dev","test:e2e":"playwright test"},
 "dependencies":{"next":"15.1.4","react":"19.0.0","@anthropic-ai/sdk":"^0.40.0"},
 "devDependencies":{"@playwright/test":"^1.49.1"}}
EOF
cat > mobile/package.json <<'EOF'
{"name":"mobile","dependencies":{"expo":"~52.0.23","expo-router":"~4.0.15","react-native":"0.76.5"}}
EOF
echo '{"expo":{"name":"store"}}' > mobile/app.json
cat > api/pyproject.toml <<'EOF'
[project]
name = "api"
dependencies = ["fastapi>=0.115", "sqlalchemy[asyncio]>=2.0", "anthropic>=0.42"]
EOF
echo 'Write a product description for: {product}' > api/app/prompts/product_description.md
echo 'name: e2e' > .github/workflows/e2e.yml
cat > TASKS.md <<'EOF'
# Tasks

## Tasks

- [ ] **Arabic option for the AI product description generator**
  - What: Sellers can choose Arabic or English before generating a description.
  - Acceptance:
    - Arabic output is Modern Standard Arabic and matches the product facts
    - English descriptions keep their current quality

- [ ] **Orders screen shows coupon discount and supports pull-to-refresh**
  - What: In the mobile app, the Orders screen shows the discount applied to each order and refreshes on pull-down.
  - Depends on: the checkout coupon fix (discounts are not being saved yet)
  - Acceptance:
    - Each order shows the discount amount
    - Pull-down refreshes the list

- [ ] **Checkout fails with a server error when a coupon is applied**
  - What: Applying WELCOME10 at checkout returns a 500 and no order is created.
  - Acceptance:
    - Order is created with the discounted total saved
    - Expired coupons show "This coupon has expired"

- [ ] **Checkout end-to-end test fails randomly in CI**
  - What: The Playwright checkout test passes locally but fails about 1 in 5 runs in CI.
  - Acceptance:
    - 20 consecutive CI runs pass
    - No sleeps or blanket retries added
EOF
