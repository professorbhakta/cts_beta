"""Idempotent Django bulk-load for seed/cts_dummy_data.xlsx.

Creates a NEW org under Admin 7069036462. Does not wipe the existing dump org.
Run inside C2S-Django: python /app/django/load_cts_dummy.py
"""

from __future__ import annotations

import os
from datetime import date, time

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "c2s.settings")

import django

django.setup()

from django.contrib.auth import get_user_model
from django.db import transaction
from django.contrib.auth.hashers import make_password

from user_servcies.models import Driver, commuter, subAdmin
from cab_services.models import Batch, Routes, cab, pickUpPoints

User = get_user_model()

PASSWORD = "password"
PASSWORD_HASH = make_password(PASSWORD)
ADMIN_MOBILE = "7069036462"
DRIVER_COUNT = 10
COMMUTER_COUNT = 1500
UG_COUNT = 750
POPS_PER_ROUTE = 8
CAB_CAPACITY = 53
COMING_PER_BATCH = 15
DRIVER_BASE = 9876544111
COMMUTER_BASE = 9876556701
STOP_NAMES = [
    "Campus Gate",
    "Railway Station",
    "City Bus Stand",
    "Market Circle",
    "Civil Hospital",
    "Housing Colony",
    "Highway Crossing",
    "College Main Gate",
]


def split_name(username: str) -> tuple[str, str]:
    parts = username.split(" ")
    if len(parts) == 2:
        return parts[0], parts[1]
    return username, ""


def get_or_create_admin() -> tuple[User, subAdmin, bool]:
    existing = User.objects.filter(mobileNumber=ADMIN_MOBILE).first()
    if existing:
        sa, _ = subAdmin.objects.get_or_create(userId=existing)
        return existing, sa, False
    first, last = split_name("Admin")
    admin = User(
        username="Admin",
        first_name=first,
        last_name=last,
        mobileNumber=ADMIN_MOBILE,
        email="admin@cts.test",
        address="admin@cts.test",
        userType="ADMIN",
        password=PASSWORD_HASH,
    )
    admin.save()
    sa = subAdmin.objects.create(userId=admin)
    return admin, sa, True


def run() -> None:
    created = {
        "admin": 0,
        "routes": 0,
        "pops": 0,
        "cabs": 0,
        "batches": 0,
        "drivers": 0,
        "commuters": 0,
        "skipped": [],
    }

    with transaction.atomic():
        admin_user, admin_sa, admin_new = get_or_create_admin()
        if admin_new:
            created["admin"] = 1
        else:
            created["skipped"].append(f"reuse admin {ADMIN_MOBILE} id={admin_user.id}")

        routes: dict[int, Routes] = {}
        pops: dict[tuple[int, int], pickUpPoints] = {}
        cabs: dict[int, cab] = {}
        batches: dict[int, Batch] = {}

        for n in range(1, DRIVER_COUNT + 1):
            route_name = f"R{n:02d}"
            route, was = Routes.objects.get_or_create(
                routeName=route_name,
                adminCode=admin_sa,
            )
            routes[n] = route
            if was:
                created["routes"] += 1

            for p, stop in enumerate(STOP_NAMES, start=1):
                pop, was = pickUpPoints.objects.get_or_create(
                    pickUpPointName=f"{route_name}-{stop}",
                    routeId=route,
                    defaults={
                        "lat": 22.30 + n * 0.01,
                        "longitude": 73.20 + p * 0.01,
                        "inLine": p,
                        "adminCode": admin_sa,
                    },
                )
                pops[(n, p)] = pop
                if was:
                    created["pops"] += 1

            cab_obj, was = cab.objects.get_or_create(
                regNumber=f"GJ-06-D-{1000 + n}",
                defaults={
                    "capacity": CAB_CAPACITY,
                    "km": 40 + n * 2,
                    "routeId": route,
                    "adminCode": admin_sa,
                },
            )
            cabs[n] = cab_obj
            if was:
                created["cabs"] += 1

            batch, was = Batch.objects.get_or_create(
                batchName=f"Batch-{n:02d}",
                adminCode=admin_sa,
                defaults={
                    "batchTime": time(7, 30 + n),
                    "end_time": time(18, 30 + n),
                    "startDate": date(2026, 8, 1),
                    "endDate": date(2026, 12, 31),
                },
            )
            batches[n] = batch
            if was:
                created["batches"] += 1

        for n in range(1, DRIVER_COUNT + 1):
            mobile = str(DRIVER_BASE + n - 1)
            name = f"Driver {n}"
            first, last = split_name(name)
            email = f"driver{n}@cts.test"
            user = User.objects.filter(mobileNumber=mobile).first()
            if user is None:
                user = User(
                    username=name,
                    first_name=first,
                    last_name=last,
                    mobileNumber=mobile,
                    email=email,
                    address=email,
                    userType="DRIVER",
                    password=PASSWORD_HASH,
                )
                user.save()
            elif user.userType != "DRIVER":
                created["skipped"].append(f"mobile {mobile} exists as {user.userType}")
                continue

            driver, was = Driver.objects.get_or_create(
                userId=user,
                defaults={
                    "adminCode": admin_sa,
                    "batchId": batches[n],
                    "cabId": cabs[n],
                },
            )
            if was:
                created["drivers"] += 1
            else:
                updated = False
                if driver.adminCode_id is None:
                    driver.adminCode = admin_sa
                    updated = True
                if driver.batchId_id is None:
                    driver.batchId = batches[n]
                    updated = True
                if driver.cabId_id is None:
                    driver.cabId = cabs[n]
                    updated = True
                if updated:
                    driver.save()

        existing_mobiles = set(
            User.objects.filter(
                mobileNumber__in=[
                    str(COMMUTER_BASE + i) for i in range(COMMUTER_COUNT)
                ]
            ).values_list("mobileNumber", flat=True)
        )
        new_users: list[User] = []
        for i in range(COMMUTER_COUNT):
            mobile = str(COMMUTER_BASE + i)
            if mobile in existing_mobiles:
                continue
            if i < UG_COUNT:
                label = f"UG{i + 1}"
            else:
                label = f"PG{i - UG_COUNT + 1}"
            email = f"{label.lower()}@cts.test"
            new_users.append(
                User(
                    username=label,
                    first_name=label,
                    last_name="",
                    mobileNumber=mobile,
                    email=email,
                    address=email,
                    userType="COMMUTER",
                    password=PASSWORD_HASH,
                )
            )
        if new_users:
            User.objects.bulk_create(new_users, batch_size=250)

        users_by_mobile = {
            u.mobileNumber: u
            for u in User.objects.filter(
                mobileNumber__in=[
                    str(COMMUTER_BASE + i) for i in range(COMMUTER_COUNT)
                ]
            )
        }
        existing_commuter_user_ids = set(
            commuter.objects.filter(
                userId__in=[u.id for u in users_by_mobile.values()]
            ).values_list("userId_id", flat=True)
        )
        new_commuters: list[commuter] = []
        for i in range(COMMUTER_COUNT):
            mobile = str(COMMUTER_BASE + i)
            user = users_by_mobile.get(mobile)
            if user is None:
                created["skipped"].append(f"missing commuter user {mobile}")
                continue
            if user.id in existing_commuter_user_ids:
                continue
            if user.userType != "COMMUTER":
                created["skipped"].append(f"mobile {mobile} exists as {user.userType}")
                continue
            batch_n = (i % DRIVER_COUNT) + 1
            pop_n = (i // DRIVER_COUNT) % POPS_PER_ROUTE + 1
            coming = (i // DRIVER_COUNT) < COMING_PER_BATCH
            college = "UG" if i < UG_COUNT else "PG"
            new_commuters.append(
                commuter(
                    collegeName=college,
                    cabId=cabs[batch_n],
                    popId=pops[(batch_n, pop_n)],
                    isComing=coming,
                    userId=user,
                    batchId=batches[batch_n],
                    adminCode=admin_sa,
                )
            )
        if new_commuters:
            commuter.objects.bulk_create(new_commuters, batch_size=250)
            created["commuters"] = len(new_commuters)

    coming_true = commuter.objects.filter(adminCode=admin_sa, isComing=True).count()
    print("LOAD_OK")
    print("admin_mobile", ADMIN_MOBILE)
    print("admin_user_id", admin_user.id)
    print("admin_code", admin_sa.id)
    print("created", created)
    print("org_routes", Routes.objects.filter(adminCode=admin_sa).count())
    print("org_pops", pickUpPoints.objects.filter(adminCode=admin_sa).count())
    print("org_cabs", cab.objects.filter(adminCode=admin_sa).count())
    print("org_batches", Batch.objects.filter(adminCode=admin_sa).count())
    print("org_drivers", Driver.objects.filter(adminCode=admin_sa).count())
    print("org_commuters", commuter.objects.filter(adminCode=admin_sa).count())
    print("org_isComing_true", coming_true)
    print("dump_admin_untouched", User.objects.filter(mobileNumber="9898927941").count())


if __name__ == "__main__":
    run()
