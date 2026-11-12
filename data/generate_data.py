#!/usr/bin/env python3
"""
Synthetic coffee-shop data generator (deterministic: same --seed -> same files).

Creates 6 CSV files:  raw_customers, raw_products, raw_orders, raw_order_items,
raw_payments, raw_stores.  The first five use EXACTLY the same columns as the
small practice dataset of the dbt Project Playbook, so the same dbt code works.

Optional real data: --products-file my_products.csv
    CSV with columns:  product_name,category,unit_price     (is_active is added automatically)
    Build it from a public dataset (for example the distinct coffee names and prices
    of a Kaggle coffee-sales file) to make the product list real.

Example:
    python generate_coffee_data.py --out data --orders 20000 --start 2024-01-01 --days 730
"""
import argparse, csv, json, os, random, bisect
from datetime import date, datetime, timedelta

FIRST = ["Anna","Ben","Clara","David","Emma","Felix","Greta","Hans","Ida","Jonas","Klara","Lukas","Mia","Noah",
         "Olivia","Paul","Quinn","Rosa","Sven","Tina","Uwe","Vera","Willi","Xenia","Yara","Zoe","Max","Lena","Tom",
         "Nora","Elias","Hannah","Leon","Sophie","Finn","Marie","Jan","Laura","Tim","Julia"]
LAST = ["Schmidt","Meyer","Weber","Wagner","Becker","Hoffmann","Koch","Richter","Klein","Wolf","Schneider","Fischer",
        "Schulz","Bauer","Zimmermann","Braun","Krueger","Hartmann","Lange","Werner","Krause","Lehmann","Schmitt",
        "Maier","Kaiser","Fuchs","Vogel","Keller","Jung","Roth"]
CITIES = ["Berlin","Leipzig","Potsdam","Dresden","Hamburg"]
STORES = [("Mitte","Berlin","2019-03-01"),("Prenzlauer Berg","Berlin","2021-06-15"),("Leipzig Zentrum","Leipzig","2023-09-01")]
DEFAULT_PRODUCTS = [("Espresso","coffee",2.50),("Latte","coffee",3.80),("Cappuccino","coffee",3.60),("Flat White","coffee",3.90),
    ("Americano","coffee",3.00),("Mocha","coffee",4.20),("Cold Brew","coffee",3.70),("Green Tea","tea",2.80),
    ("Chai Latte","tea",4.00),("Iced Tea","tea",3.10),("Croissant","pastry",2.90),("Blueberry Muffin","pastry",3.20),
    ("Cheesecake Slice","pastry",4.50),("Cinnamon Roll","pastry",3.40)]
HOUR_W = {7:6,8:14,9:12,10:8,11:7,12:11,13:10,14:7,15:6,16:5,17:4,18:2}
DOW_W = [1.0,1.0,1.0,1.0,1.1,1.3,0.8]           # Mon..Sun
COLD = {"Cold Brew","Iced Tea"}; WARM = {"Chai Latte","Mocha","Cinnamon Roll"}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="data"); ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--orders", type=int, default=20000); ap.add_argument("--customers", type=int, default=1500)
    ap.add_argument("--start", default="2024-01-01"); ap.add_argument("--days", type=int, default=730)
    ap.add_argument("--products-file", default=None)
    a = ap.parse_args()
    rnd = random.Random(a.seed); os.makedirs(a.out, exist_ok=True)
    start = date.fromisoformat(a.start)

    # ---- products
    if a.products_file:
        with open(a.products_file, newline="") as f:
            prods = [(r["product_name"].strip(), r["category"].strip().lower(), float(r["unit_price"])) for r in csv.DictReader(f)]
    else:
        prods = DEFAULT_PRODUCTS
    products = [[i+1, n, c, f"{p:.2f}", "false" if n == "Cold Brew" and not a.products_file else "true"] for i,(n,c,p) in enumerate(prods)]
    price = {r[0]: float(r[3]) for r in products}; pname = {r[0]: r[1] for r in products}
    base_w = {r[0]: rnd.choice([3,4,5,6,8,10]) if r[2] in ("coffee","tea") else rnd.choice([2,3,4]) for r in products}

    # ---- customers (signup spread over the 18 months before the start + the first year)
    customers = []; signups = []
    for i in range(1, a.customers+1):
        f, l = rnd.choice(FIRST), rnd.choice(LAST)
        signup = start - timedelta(days=540) + timedelta(days=int(i * (540 + 365) / a.customers))
        city = rnd.choice(CITIES)
        if rnd.random() < 0.03: city = city.lower()                       # dirty: lower case
        email = "" if rnd.random() < 0.01 else f"{f.lower()}.{l.lower()}{i}@example.com"   # dirty: missing
        tier = rnd.choices(["bronze","silver","gold"], [6,3,1])[0]
        upd = signup if rnd.random() > 0.15 else signup + timedelta(days=rnd.randint(30, 400))
        customers.append([i, f, l, email, city, signup.isoformat(), tier, f"{upd.isoformat()} 00:00:00"]); signups.append(signup)

    # ---- order timestamps (weekday and hour patterns), sorted so ids increase with time
    days = [start + timedelta(days=d) for d in range(a.days)]
    dweights = [DOW_W[d.weekday()] for d in days]
    hours = list(HOUR_W.keys()); hweights = list(HOUR_W.values())
    stamps = []
    for _ in range(a.orders):
        d = rnd.choices(days, dweights)[0]; h = rnd.choices(hours, hweights)[0]
        stamps.append(datetime(d.year, d.month, d.day, h, rnd.randint(0, 59), rnd.randint(0, 59)))
    stamps.sort()

    orders, items, payments = [], [], []; oi = pid = 0; anomalies = {"payment_mismatch_orders": [], "guest_orders": 0, "cancelled": 0, "returned": 0}
    for oid, ts in enumerate(stamps, 1):
        r = rnd.random()
        status = "cancelled" if r < 0.05 else "returned" if r < 0.09 else "completed"
        anomalies["cancelled" if status == "cancelled" else "returned" if status == "returned" else "guest_orders"] += 0 if status == "completed" else 1
        if rnd.random() < 0.08: cust = ""; anomalies["guest_orders"] += 1
        else:
            eligible = bisect.bisect_right(signups, ts.date())
            cust = rnd.randint(1, max(1, eligible))
        store = rnd.choices([s[0] for s in STORES], [5,4,2 if ts.date() >= date(2023,9,1) else 0])[0]
        orders.append([oid, cust, ts.strftime("%Y-%m-%d %H:%M:%S"), status, store])
        total = 0.0
        for _ in range(rnd.choices([1,2,3,4], [50,30,15,5])[0]):
            oi += 1
            w = []
            for pid_, nm in pname.items():
                x = base_w[pid_]
                if nm in COLD: x *= 2.5 if ts.month in (6,7,8) else 0.4
                if nm in WARM: x *= 2.0 if ts.month in (11,12,1,2) else 0.7
                w.append(x)
            pr = rnd.choices(list(pname.keys()), w)[0]; q = rnd.choices([1,2,3], [70,25,5])[0]
            items.append([oi, oid, pr, q]); total += price[pr] * q
        if status != "cancelled":
            pid += 1; cents = round(total * 100)
            if rnd.random() < 0.0015: cents += rnd.choice([-100, 100, 50]); anomalies["payment_mismatch_orders"].append(oid)
            payments.append([pid, oid, rnd.choices(["card","app","cash"], [55,30,15])[0], cents, (ts + timedelta(minutes=1)).strftime("%Y-%m-%d %H:%M:%S")])
    dup_n = max(3, int(len(orders) * 0.003)); dup_ids = sorted(rnd.sample(range(1, len(orders)+1), dup_n))
    for d in dup_ids: orders.append(list(orders[d-1]))
    anomalies["duplicate_order_rows"] = dup_ids

    def w(name, header, rows):
        with open(os.path.join(a.out, name + ".csv"), "w", newline="") as f:
            cw = csv.writer(f, lineterminator="\n"); cw.writerow(header); cw.writerows(rows)
    w("raw_customers", ["customer_id","first_name","last_name","email","city","signup_date","loyalty_tier","updated_at"], customers)
    w("raw_products", ["product_id","product_name","category","unit_price","is_active"], products)
    w("raw_orders", ["order_id","customer_id","order_ts","status","store"], orders)
    w("raw_order_items", ["order_item_id","order_id","product_id","quantity"], items)
    w("raw_payments", ["payment_id","order_id","payment_method","amount_cents","created_at"], payments)
    w("raw_stores", ["store_name","city","opened_date"], [list(s) for s in STORES])
    rep = dict(customers=len(customers), products=len(products), order_rows=len(orders), distinct_orders=len(stamps),
               order_items=len(items), payments=len(payments), first_order=orders[0][2], last_order=max(o[2] for o in orders),
               missing_emails=sum(1 for c in customers if not c[3]), lowercase_cities=sum(1 for c in customers if c[4].islower()),
               **anomalies)
    json.dump(rep, open(os.path.join(a.out, "data_report.json"), "w"), indent=1)
    print(json.dumps(rep, indent=1))

if __name__ == "__main__":
    main()