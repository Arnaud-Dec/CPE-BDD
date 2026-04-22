```bash
docker run -d \
  --name postgres-db \
  -e POSTGRES_PASSWORD=mon_mot_de_passe \
  -p 5432:5432 \
  postgres:18.3

```