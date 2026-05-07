```bash
docker run -d \
  --name postgres-db \
  -e POSTGRES_PASSWORD=mon_mot_de_passe \
  -p 5432:5432 \
  postgres:18.3

```

```bash
docker run -d \
  --name pgadmin \
  -p 5050:80 \
  -e "PGADMIN_DEFAULT_EMAIL=admin@admin.com" \
  -e "PGADMIN_DEFAULT_PASSWORD=admin" \
  dpage/pgadmin4:2026-05-06-1
```