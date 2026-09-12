"""End-to-end API test: health -> register -> login -> predict -> history."""
import json
import urllib.request
import urllib.error

BASE = "http://127.0.0.1:8000"


def call(method, path, body=None, token=None):
    url = BASE + path
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Content-Type", "application/json")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    try:
        with urllib.request.urlopen(req) as r:
            return r.status, json.loads(r.read().decode())
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read().decode())


profile = {
    "HighBP": 1, "HighChol": 1, "CholCheck": 1, "BMI": 34.0, "Smoker": 1,
    "Stroke": 0, "HeartDiseaseorAttack": 0, "PhysActivity": 0, "Fruits": 0,
    "Veggies": 0, "HvyAlcoholConsump": 0, "AnyHealthcare": 1, "NoDocbcCost": 0,
    "GenHlth": 4, "MentHlth": 5, "PhysHlth": 10, "DiffWalk": 1, "Sex": 1,
    "Age": 10, "Education": 4, "Income": 5,
}

print("1) HEALTH        ", call("GET", "/api/health/"))

s, r = call("POST", "/api/auth/register/",
            {"username": "rohan_demo", "email": "demo@fyp.com", "password": "StrongPass123"})
print("2) REGISTER      ", s, r)

s, r = call("POST", "/api/auth/login/",
            {"username": "rohan_demo", "password": "StrongPass123"})
print("3) LOGIN         ", s, "access token received" if "access" in r else r)
token = r.get("access")

s, r = call("POST", "/api/predict/", profile, token=token)
print("4) PREDICT       ", s)
if s == 200:
    print(json.dumps(r["prediction"], indent=2))
    print("   top diabetes factor:", r["key_factors"]["diabetes"][0])
    print("   first recommendation:", r["recommendations"][0])
else:
    print("   ", r)

s, r = call("GET", "/api/predict/", token=token)  # wrong method check
s, r = call("GET", "/api/history/", token=token)
print("5) HISTORY       ", s, f"{len(r)} record(s)" if isinstance(r, list) else r)

s, r = call("POST", "/api/predict/", profile)  # no token
print("6) AUTH GUARD    ", s, "(401 expected when no token)")
